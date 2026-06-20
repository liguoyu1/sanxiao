extends Control

const HC = preload("res://scripts/hex_coord.gd")
const GL = preload("res://scripts/game_loop.gd")
const LD = preload("res://scripts/level_data.gd")

@onready var bc = $BoardContainer
@onready var rdr = $BoardContainer/BoardRenderer
@onready var mgr = $LevelManager
@onready var hud = $HUD

var result_screen
var board
var game_loop

func _ready():
	if not ResourceLoader.exists("res://scenes/levels/level_001.tres"):
		mgr.generate_all_levels()

	var rs_scene = load("res://scenes/result_screen.tscn")
	if rs_scene:
		result_screen = rs_scene.instantiate()
		add_child(result_screen)
		result_screen.action_next.connect(_on_next)
		result_screen.action_retry.connect(_on_retry)
		result_screen.action_quit.connect(_on_quit)

	hud.level_result.connect(_on_hud_level_result)
	hud.power_pressed.connect(_on_power_pressed)
	start_level(GameFlow.current_level)

func start_level(id: int):
	rdr.clear()
	if game_loop:
		game_loop.queue_free()
	var HB = load("res://scripts/hex_board.gd")
	board = HB.new()
	board.initialize()
	rdr.initialize(board)
	var DH = load("res://scripts/drag_handler.gd")
	game_loop = Node.new()
	game_loop.set_script(GL)
	game_loop.setup(rdr, board)
	game_loop.score_changed.connect(_on_score_changed)
	game_loop.swap_performed.connect(func(): hud.use_step())
	game_loop.match_resolved.connect(func(_m): hud.add_loop())
	add_child(game_loop)
	var drag = Node.new()
	drag.set_script(DH)
	drag.setup(rdr, board, game_loop)
	add_child(drag)
	hud.setup_for_level(mgr.get_level(id))
	if result_screen:
		result_screen.hide()
	AudioManager.start_bgm()

func _on_hud_level_result(s):
	var lv = mgr.get_level(GameFlow.current_level)
	if lv == null:
		return
	var ok: bool
	if lv.mode == LD.Mode.TIMED:
		ok = s > 0
	else:
		ok = (lv.target_score <= 0 or s >= lv.target_score) \
			and (lv.target_loops <= 0 or hud.loops_made >= lv.target_loops)

	var stars = _calc_stars(s, ok, lv)
	GameFlow.on_level_complete(s, stars)

	if ok:
		AudioManager.play_win()
	else:
		AudioManager.play_lose()

	if not result_screen:
		return
	await get_tree().create_timer(0.5).timeout
	result_screen.show_result(ok, s, stars)

func _calc_stars(score: int, won: bool, lv) -> int:
	if not won:
		return 0
	var stars = 1
	if lv.target_score <= 0 or score >= lv.target_score * 1.5:
		stars = 2
	if lv.target_loops <= 0 or hud.loops_made >= lv.target_loops * 2:
		stars = 3
	return stars

func _on_score_changed(s: int) -> void:
	hud.update_score(s)

func _on_power_pressed(idx: int) -> void:
	if game_loop and game_loop.use_power(idx):
		AudioManager.play_power()

func _on_next():
	AudioManager.play_click()
	GameFlow.next_level()

func _on_retry():
	AudioManager.play_click()
	GameFlow.retry_level()

func _on_quit():
	AudioManager.play_click()
	GameFlow.go_to_level_select()
