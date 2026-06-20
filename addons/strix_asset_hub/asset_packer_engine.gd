@tool
extends RefCounted
## STRIX Asset Hub - Engine Facade
## Orchestrates high-level packaging workflows. Adds error signaling and manifest version validation.

signal progress_updated(current: int, total: int)
signal task_finished(success_count: int, total_count: int, save_path: String)
signal import_finished(success: bool, message: String)
signal error_occurred(code: int, message: String)

const ERR_INVALID_MANIFEST: int = 1
const ERR_FILE_ACCESS: int = 2
const CURRENT_MANIFEST_VERSION: String = "1.0"

var _scanner: RefCounted
var _autoload_mgr: RefCounted
var _zip_handler: RefCounted

func _init() -> void:
	_scanner = preload("./core/dependency_scanner.gd").new()
	_autoload_mgr = preload("./core/autoload_manager.gd").new()
	_zip_handler = preload("./core/zip_handler.gd").new()

	# Forward internal progress/task signals to public API
	_scanner.progress_updated.connect(func(c, t): progress_updated.emit(c, t))
	_zip_handler.progress_updated.connect(func(c, t): progress_updated.emit(c, t))
	_zip_handler.task_finished.connect(func(s, t, p): task_finished.emit(s, t, p))
	_zip_handler.extract_finished.connect(func(s, m): import_finished.emit(s, m))
	
	# Wire error signals for centralized handling
	_scanner.error_occurred.connect(func(c, m): error_occurred.emit(c, m))
	_zip_handler.error_occurred.connect(func(c, m): error_occurred.emit(c, m))

## Recursively collects all file paths under a directory, excluding engine internals.
func get_all_files_in_dir(path: String) -> Array[String]:
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(path)
	if not dir: return files
	for file in dir.get_files(): files.append(path.path_join(file))
	for folder in dir.get_directories():
		if folder in [".godot", ".git"]: continue
		files.append_array(get_all_files_in_dir(path.path_join(folder)))
	return files

## Orchestrates dependency scanning with autoload detection and path validation.
func collect_dependencies(start_files: Array[String], tree: SceneTree) -> Dictionary:
	var registered_autoloads: Dictionary = _autoload_mgr.get_registered_autoloads()
	var scan_result: Dictionary = await _scanner.scan(start_files, tree, registered_autoloads)
	return {
		"to_pack": scan_result.get("files", []),
		"missing": scan_result.get("missing", []),
		"autoloads": scan_result.get("used_autoloads", {})
	}

## Creates a ZIP archive containing the specified files and autoload metadata.
func create_zip(save_path: String, files: Array[String], autoloads: Dictionary, tree: SceneTree) -> Error:
	return await _zip_handler.create_zip(save_path, files, autoloads, tree)

## Imports a STRIX package by extracting files and injecting autoload configurations.
func import_zip(zip_path: String, tree: SceneTree) -> void:
	var reader: ZIPReader = ZIPReader.new()
	if reader.open(zip_path) != OK:
		error_occurred.emit(ERR_FILE_ACCESS, "Failed to open ZIP archive. Verify file integrity.")
		return

	# STEP 1: Parse manifest & validate version
	var manifest_data: Dictionary = {}
	if reader.get_files().has("strix_manifest.json"):
		var content: PackedByteArray = reader.read_file("strix_manifest.json")
		var json: JSON = JSON.new()
		if json.parse(content.get_string_from_utf8()) == OK:
			manifest_data = json.data

	var pkg_version: String = manifest_data.get("version", "0.0")
	if pkg_version != CURRENT_MANIFEST_VERSION:
		reader.close()
		error_occurred.emit(ERR_INVALID_MANIFEST, 
			"Incompatible package version (%s). Expected %s. Please repack with the latest STRIX version." % 
			[pkg_version, CURRENT_MANIFEST_VERSION])
		return

	# STEP 2: Inject autoloads BEFORE extracting other files
	var autoloads_to_inject: Dictionary = manifest_data.get("autoloads", {})
	_autoload_mgr.inject_autoloads(autoloads_to_inject)

	# STEP 3: Extract & signal completion
	_zip_handler.extract_zip(zip_path, autoloads_to_inject, tree)

	if not import_finished.is_connected(_on_import_finalized):
		import_finished.connect(_on_import_finalized)

func _on_import_finalized(_success: bool, _message: String) -> void:
	import_finished.disconnect(_on_import_finalized)
	print_rich("[color=yellow][STRIX][/color] Workspace update complete. Temporary console warnings during extraction are safe to ignore.")
	EditorInterface.get_resource_filesystem().scan()