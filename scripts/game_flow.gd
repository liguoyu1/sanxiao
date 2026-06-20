extends Node
signal before_level_start(level_id: int)

var current_level: int = 1
var last_result: Dictionary = {}

func _get_audio() -> Node:
	return Engine.get_singleton("AudioManager")

func _get_save() -> Node:
	return Engine.get_singleton("SaveManager")

func go_to_main_menu() -> void:
	var am = _get_audio()
	if am: am.stop_bgm()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func go_to_level_select() -> void:
	var am = _get_audio()
	if am: am.stop_bgm()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func start_level(level_id: int) -> void:
	current_level = level_id
	before_level_start.emit(level_id)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func retry_level() -> void:
	start_level(current_level)

func next_level() -> void:
	var sm = _get_save()
	if sm and sm.is_unlocked(current_level + 1):
		start_level(current_level + 1)
	else:
		go_to_level_select()

func on_level_complete(score: int, stars: int) -> void:
	last_result = {"score": score, "stars": stars, "won": stars > 0}
	var sm = _get_save()
	if sm:
		sm.set_stars(current_level, stars)
