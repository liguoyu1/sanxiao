@tool
extends EditorPlugin
## STRIX Asset Hub - Plugin Entry Point
## Manages the lifecycle of the STRIX Asset Hub dock within the Godot Editor.
## Responsible for instantiating, positioning, and cleaning up the dock UI.

const DOCK_SCENE: PackedScene = preload("./packager_dock.tscn")
var _dock_instance: Control

## Called when the plugin is enabled. Instantiates and positions the dock.
func _enter_tree() -> void:
	_dock_instance = DOCK_SCENE.instantiate()
	_dock_instance.name = "Asset Hub"
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, _dock_instance)

## Called when the plugin is disabled. Safely removes and frees the dock.
func _exit_tree() -> void:
	if is_instance_valid(_dock_instance):
		remove_control_from_docks(_dock_instance)
		_dock_instance.free()
		_dock_instance = null