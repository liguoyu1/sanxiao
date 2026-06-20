@tool
extends RefCounted
## STRIX Asset Hub - Dependency Scanner
##
## Performs asynchronous breadth-first traversal to discover all resource dependencies
## starting from user-specified entry points. Handles Godot 4.x UID resolution,
## text-based preload/load detection, and smart Autoload reference scanning.
##
## Performance Notes:
## - Uses index-based queue (O(1)) instead of pop_front() (O(n))
## - Dynamic yield intervals target ~60 FPS editor responsiveness
## - Regex patterns precompiled and cached statically

signal progress_updated(current: int, total: int)
signal error_occurred(code: int, message: String)

const TARGET_FPS: int = 60

# Statically cached regex patterns to avoid recompilation overhead.
static var _preload_regex: RegEx
static var _comment_strip_regex: RegEx
static var _autoload_patterns: Dictionary = {}

func _init() -> void:
	if not _preload_regex:
		_preload_regex = RegEx.new()
		# Matches preload("res://...") or load("res://...") with flexible whitespace
		_preload_regex.compile(r"(?:preload|load)\s*\(\s*['\"](res://[^'\"]+)['\"]\s*\)")
	if not _comment_strip_regex:
		_comment_strip_regex = RegEx.new()
		# Matches single-line GDScript comments starting with #
		_comment_strip_regex.compile(r"(?m)(?<=^|\s)#.*$")

## Main entry point for dependency scanning.
## @param start_files: Initial files/folders to traverse
## @param tree: SceneTree for async yielding
## @param registered_autoloads: Project autoloads from ProjectSettings
## @return: Dictionary with "files", "missing", "used_autoloads"
func scan(start_files: Array[String], tree: SceneTree, registered_autoloads: Dictionary) -> Dictionary:
	var collected: Dictionary = {}
	var missing: Array[String] = []
	var queue: Array[String] = start_files.duplicate()
	var index: int = 0
	var iterations: int = 0
	var yield_interval: int = max(1, int(queue.size() / TARGET_FPS) + 1)

	while index < queue.size():
		var path: String = _normalize_path(queue[index])
		index += 1

		if collected.has(path):
			continue
		if not FileAccess.file_exists(path):
			if not missing.has(path):
				missing.append(path)
			continue

		collected[path] = true
		_include_import_pair(path, collected)
		_resolve_binary_dependencies(path, queue, collected)
		_resolve_text_dependencies(path, queue, collected)

		iterations += 1
		if iterations % yield_interval == 0:
			progress_updated.emit(index, queue.size())
			await tree.process_frame

	progress_updated.emit(index, queue.size())

	var file_list: Array[String] = []
	file_list.assign(collected.keys())
	var used_autoloads: Dictionary = _scan_autoload_references(registered_autoloads, file_list)
	_inject_autoload_files(used_autoloads, collected)

	return {
		"files": collected.keys(),
		"missing": missing,
		"used_autoloads": used_autoloads
	}

## Normalizes a path by extracting the res:// portion.
func _normalize_path(input: String) -> String:
	var idx: int = input.find("res://")
	return input.substr(idx) if idx != -1 else input

## Includes the paired .import file if it exists for texture/asset preservation.
func _include_import_pair(base_path: String, collected: Dictionary) -> void:
	var import_path: String = base_path + ".import"
	if FileAccess.file_exists(import_path):
		collected[import_path] = true

## Resolves binary resource dependencies via ResourceLoader and UID cache.
func _resolve_binary_dependencies(file_path: String, queue: Array[String], collected: Dictionary) -> void:
	if not ResourceLoader.exists(file_path):
		return
	for dep in ResourceLoader.get_dependencies(file_path):
		var resolved: String = _resolve_uid_reference(dep)
		# Safe check: skip if resolution failed or path already tracked
		if resolved.is_empty() or collected.has(resolved):
			continue
		queue.append(resolved)

## Resolves Godot 4.x UID references to concrete res:// paths.
func _resolve_uid_reference(input: String) -> String:
	if not input.begins_with("uid://"):
		var idx: int = input.find("res://")
		return input.substr(idx) if idx != -1 else input
	var res_idx: int = input.find("res://")
	if res_idx != -1:
		return input.substr(res_idx)
	var uid: int = ResourceUID.text_to_id(input)
	return ResourceUID.get_id_path(uid) if ResourceUID.has_id(uid) else ""

## Scans text files for preload/load calls and queues discovered paths.
func _resolve_text_dependencies(file_path: String, queue: Array[String], collected: Dictionary) -> void:
	if not _is_text_file(file_path):
		return
	var content: String = FileAccess.get_file_as_string(file_path)
	if content.is_empty():
		return
	for match in _preload_regex.search_all(content):
		var dep: String = match.get_string(1)
		if not collected.has(dep) and not queue.has(dep):
			queue.append(dep)

## Checks if a file extension indicates parseable text content.
func _is_text_file(path: String) -> bool:
	return path.ends_with(".gd") or path.ends_with(".tscn") or path.ends_with(".tres")

## Scans collected files for actual Autoload usage patterns (not just mentions).
func _scan_autoload_references(registered: Dictionary, files: Array) -> Dictionary:
	var used: Dictionary = {}
	if registered.is_empty() or files.is_empty():
		return used

	# Precompile usage patterns for each autoload name
	for name in registered:
		if not _autoload_patterns.has(name):
			var safe: String = _escape_regex(name)
			var pattern: RegEx = RegEx.new()
			# Matches: Name. Name[ Name( /root/Name" $Name.
			pattern.compile(r"\b" + safe + r"\s*[\.\[\(]|/root/" + safe + r"\"|\$" + safe + r"\s*\.")
			_autoload_patterns[name] = pattern

	for file_path in files:
		if not _is_text_file(file_path):
			continue
		var raw: String = FileAccess.get_file_as_string(file_path)
		if raw.is_empty():
			continue
		var clean: String = _comment_strip_regex.sub(raw, "", true)
		for name in registered:
			if _autoload_patterns[name].search(clean):
				used[name] = registered[name]
	return used

## Adds detected autoload script paths to the collected files set.
func _inject_autoload_files(autoloads: Dictionary, collected: Dictionary) -> void:
	for path in autoloads.values():
		if not collected.has(path) and FileAccess.file_exists(path):
			collected[path] = true
			var import_path: String = path + ".import"
			if FileAccess.file_exists(import_path):
				collected[import_path] = true

## Escapes regex metacharacters for safe pattern compilation.
func _escape_regex(text: String) -> String:
	var result: String = ""
	# Added '-' to ensure safe dynamic pattern generation
	for char in text:
		result += "\\" + char if char in "\\^$.|?*+()[]{}-" else char
	return result