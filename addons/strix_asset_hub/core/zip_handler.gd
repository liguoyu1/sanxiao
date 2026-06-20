@tool
extends RefCounted
## STRIX Asset Hub - ZIP Handler
##
## Manages archive creation and extraction with embedded manifest support.
## Implements async processing with dynamic yielding to maintain editor responsiveness.
##
## Manifest Format (strix_manifest.json):
## {
##   "version": "1.0",
##   "autoloads": { "AudioManager": "res://globals/audio_manager.gd" }
## }

signal progress_updated(current: int, total: int)
signal task_finished(success_count: int, total_count: int, save_path: String)
signal extract_finished(success: bool, message: String)
signal error_occurred(code: int, message: String)

const TARGET_FPS: int = 60

## Creates a ZIP archive with embedded manifest and async progress reporting.
## @param save_path: Destination path for the archive
## @param files: Array of res:// paths to include
## @param autoloads: Autoload configs to embed in manifest
## @param tree: SceneTree for yielding
## @return: Error code (OK on success)
func create_zip(save_path: String, files: Array[String], autoloads: Dictionary, tree: SceneTree) -> Error:
	var packer: ZIPPacker = ZIPPacker.new()
	if packer.open(save_path) != OK:
		error_occurred.emit(2, "Cannot create ZIP at: %s. Check folder permissions." % save_path)
		task_finished.emit(0, 0, "")
		return ERR_FILE_CANT_OPEN

	# Embed manifest as first entry for O(1) access during import
	var manifest: Dictionary = {"version": "1.0", "autoloads": autoloads}  # Hardcode version for now, can be dynamic later
	packer.start_file("strix_manifest.json")
	packer.write_file(JSON.stringify(manifest, "\t").to_utf8_buffer())
	packer.close_file()

	var success: int = 0
	var yield_interval: int = max(1, int(files.size() / TARGET_FPS) + 1)

	for i in range(files.size()):
		var internal_path: String = files[i].trim_prefix("res://")
		var file: FileAccess = FileAccess.open(files[i], FileAccess.READ)
		if file:
			packer.start_file(internal_path)
			packer.write_file(file.get_buffer(file.get_length()))
			packer.close_file()
			success += 1

		progress_updated.emit(i + 1, files.size())
		if i % yield_interval == 0:
			await tree.process_frame

	packer.close()
	task_finished.emit(success, files.size(), save_path)
	return OK

## Extracts a STRIX archive with priority handling for autoload scripts.
## @param zip_path: Path to the source ZIP file
## @param autoloads_to_inject: Autoload configs to register before extraction
## @param tree: SceneTree for yielding
func extract_zip(zip_path: String, autoloads_to_inject: Dictionary, tree: SceneTree) -> void:
	var reader: ZIPReader = ZIPReader.new()
	if reader.open(zip_path) != OK:
		extract_finished.emit(false, "❌ Failed to open archive. Verify file integrity.")
		return

	var entries: PackedStringArray = reader.get_files()
	var success: int = 0
	var yield_interval: int = max(1, int(entries.size() / TARGET_FPS) + 1)
	var extracted: Dictionary = {}  # O(1) lookup for duplicate prevention

	# Priority extract autoload scripts first
	for name in autoloads_to_inject:
		var path: String = autoloads_to_inject[name]
		var internal: String = path.trim_prefix("res://")
		if entries.has(internal) and not extracted.has(internal):
			_extract_file(reader, internal, "res://")
			success += 1
			extracted[internal] = true

	# Extract remaining files
	for i in range(entries.size()):
		var entry: String = entries[i]
		if extracted.has(entry) or entry == "strix_manifest.json":
			continue
		_extract_file(reader, entry, "res://")
		success += 1
		extracted[entry] = true
		progress_updated.emit(i + 1, entries.size())
		if i % yield_interval == 0:
			await tree.process_frame

	reader.close()
	extract_finished.emit(true, "✅ Imported %d items. Check FileSystem for updates." % success)

## Helper: Safely extracts a single file from archive to project directory.
func _extract_file(reader: ZIPReader, internal_path: String, base_prefix: String) -> void:
	var content: PackedByteArray = reader.read_file(internal_path)
	var output_path: String = base_prefix + internal_path
	var dir: String = output_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var file: FileAccess = FileAccess.open(output_path, FileAccess.WRITE)
	if file:
		file.store_buffer(content)
		file.close()