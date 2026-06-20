extends ColorRect

const TOTAL_LEVELS := 50
const COLS := 5

@onready var grid = $GridContainer
@onready var scroll = $ScrollContainer
@onready var back_btn = $BackBtn

var _level_btns: Array[Button] = []

func _ready() -> void:
	back_btn.pressed.connect(func():
		AudioManager.play_click()
		GameFlow.go_to_main_menu())
	_build_grid()

func _build_grid() -> void:
	grid.columns = COLS
	for c in grid.get_children():
		c.queue_free()
	_level_btns.clear()

	for i in range(1, TOTAL_LEVELS + 1):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(100, 100)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var unlocked = SaveManager.is_unlocked(i)
		var stars = SaveManager.get_stars(i)

		btn.text = "%d" % i
		btn.disabled = not unlocked

		if unlocked:
			btn.pressed.connect(_on_level_pressed.bind(i))
			var star_str = ""
			for s in stars:
				star_str += "★"
			if stars > 0:
				btn.text += "\n" + star_str

		var ld = _get_level_data(i)
		if ld:
			btn.tooltip_text = ld.display_name

		grid.add_child(btn)
		_level_btns.append(btn)

func _on_level_pressed(id: int) -> void:
	AudioManager.play_click()
	GameFlow.start_level(id)

func _get_level_data(id: int):
	var path = "res://scenes/levels/level_%03d.tres" % id
	if ResourceLoader.exists(path):
		return load(path)
	return null
