extends Node
## 存档系统 — ConfigFile 持久化玩家进度
## autoload 注册为 "SaveManager"

const SAVE_PATH := "user://save.cfg"

var max_unlocked: int = 1
var level_stars: Dictionary = {}  # level_id -> stars (0-3)
var power_inventory: Array[int] = [1, 1, 1, 1]
var selected_theme: String = "default"

func _ready() -> void:
	load_game()

func save_game() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("progress", "max_unlocked", max_unlocked)
	cfg.set_value("progress", "selected_theme", selected_theme)

	var stars_arr = []
	for key in level_stars:
		stars_arr.append([int(key), level_stars[key]])
	cfg.set_value("progress", "level_stars", stars_arr)
	cfg.set_value("inventory", "powers", power_inventory)
	cfg.save(SAVE_PATH)

func load_game() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		reset()
		return

	max_unlocked = cfg.get_value("progress", "max_unlocked", 1)
	selected_theme = cfg.get_value("progress", "selected_theme", "default")
	power_inventory = cfg.get_value("inventory", "powers", [1, 1, 1, 1])

	var stars_arr = cfg.get_value("progress", "level_stars", [])
	level_stars.clear()
	for entry in stars_arr:
		if entry is Array and entry.size() >= 2:
			level_stars[entry[0]] = entry[1]

func set_stars(level_id: int, stars: int) -> void:
	if level_stars.get(level_id, 0) < stars:
		level_stars[level_id] = stars
	if level_id >= max_unlocked:
		max_unlocked = level_id + 1
	save_game()

func get_stars(level_id: int) -> int:
	return level_stars.get(level_id, 0)

func is_unlocked(level_id: int) -> bool:
	return level_id <= max_unlocked

func unlock_next() -> void:
	max_unlocked += 1
	save_game()

func reset() -> void:
	max_unlocked = 1
	level_stars.clear()
	power_inventory = [1, 1, 1, 1]
	selected_theme = "default"
	save_game()
