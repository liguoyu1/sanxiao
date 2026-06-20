@tool
extends RefCounted
## STRIX Asset Hub - Autoload Manager
##
## Handles ProjectSettings integration for Godot Autoloads (Singletons).
## Responsible for reading registered autoloads, filtering used ones,
## and injecting configurations during package import.
##
## Design Note: Decoupled from DependencyScanner to maintain SRP
## and enable independent testing of ProjectSettings logic.

## Retrieves all autoloads currently registered in ProjectSettings.
## @return: Dictionary mapping {autoload_name: res://script_path}
func get_registered_autoloads() -> Dictionary:
	var result: Dictionary = {}
	for prop in ProjectSettings.get_property_list():
		if not prop.name.begins_with("autoload/"):
			continue
		var name: String = prop.name.trim_prefix("autoload/")
		var value = ProjectSettings.get_setting(prop.name)
		# Godot marks autoloads with a leading "*" in the setting value
		if value is String and value.begins_with("*"):
			result[name] = value.trim_prefix("*")
	return result

## Reserved for future external API use — not currently called internally.
## Filters registered autoloads to only those actively referenced in code.
## @param found_names: Autoload names detected during dependency scan
## @return: Subset of registered autoloads that are actually used
func filter_used_autoloads(found_names: Array[String]) -> Dictionary:
	var registered: Dictionary = get_registered_autoloads()
	var used: Dictionary = {}
	for name in found_names:
		if registered.has(name):
			used[name] = registered[name]
	return used

## Injects autoload configurations into ProjectSettings and persists to disk.
## Critical: Must run BEFORE extracting dependent scripts to avoid compile errors.
## @param autoloads: Dictionary {name: res://path} to register
func inject_autoloads(autoloads: Dictionary) -> void:
	if autoloads.is_empty():
		return
	for name in autoloads:
		var path: String = autoloads[name]
		ProjectSettings.set_setting("autoload/" + name, "*" + path)
	ProjectSettings.save()
	print("[STRIX] Registered autoloads: ", autoloads.keys())