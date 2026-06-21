extends Node

const HC = preload("res://scripts/hex_coord.gd")
const MR = preload("res://scripts/match_resolver.gd")
const TF = preload("res://scripts/tile_fall.gd")

func _am(): return get_node("/root/AudioManager")

signal score_changed(s: int)
signal swap_performed()
signal match_resolved(matches: Array)
signal ripple_triggered()

var board
var renderer
var _match_resolver: MR
var _fall: TF
var _fx
var _ripple
var score: int = 0

func setup(rdr, brd):
	renderer = rdr
	board = brd
	_match_resolver = MR.new()
	_fall = TF.new()
	_fx = rdr.get_node("../ParticleFX")
	if _fx and _fx.has_method("setup"):
		_fx.setup(rdr)
	_ripple = rdr.get_node("../RippleSystem")
	if _ripple:
		if _ripple.has_method("setup"):
			_ripple.setup(rdr, brd)
		_ripple.ripple_completed.connect(_on_ripple_done)

func _resolve_swap(c1, c2):
	if c1 == null or c2 == null:
		return
	var hc1 = board.grid[c1.q][c1.r]
	var hc2 = board.grid[c2.q][c2.r]
	var t1 = renderer.get_tile(c1)
	var t2 = renderer.get_tile(c2)
	if not renderer._tiles.has(c1) or not renderer._tiles.has(c2):
		return
	t1 = renderer._tiles[c1]
	t2 = renderer._tiles[c2]
	renderer._tiles[c1] = t2
	renderer._tiles[c2] = t1
	if t1: t1.color_index = c2.color; t1.redraw()
	if t2: t2.color_index = c1.color; t2.redraw()

	var p1 = hc1.to_pixel(renderer.hex_size)
	var p2 = hc2.to_pixel(renderer.hex_size)
	var tw = create_tween().set_parallel(true)
	if t1: tw.tween_property(t1, "position", p2, 0.25).set_ease(Tween.EASE_IN_OUT)
	if t2: tw.tween_property(t2, "position", p1, 0.25).set_ease(Tween.EASE_IN_OUT)
	_am().play_swap()
	swap_performed.emit()
	tw.tween_callback(_resolve_loop)

func _resolve_loop() -> void:
	var matches = _match_resolver.resolve()
	if matches.size() == 0:
		score_changed.emit(score)
		_unlock()
		return

	score = _match_resolver.score
	score_changed.emit(score)
	match_resolved.emit(matches)
	_am().play_match()

	var positions = []
	for m in matches:
		for hc in m.cells:
			positions.append(hc.to_pixel(renderer.hex_size))
	_fx.play_remove_fx(positions)

	var tw = create_tween()
	tw.tween_interval(0.3)
	tw.tween_callback(func():
		_ripple.trigger_ripple(matches)
		_am().play_ripple()
		ripple_triggered.emit()
	)
	tw.tween_interval(0.3)
	tw.tween_callback(func():
		_fall.apply_fall()
		if randf() < 0.2:
			_power_up.random_drop()
	)
	tw.tween_interval(0.4)
	tw.tween_callback(_resolve_loop)

func _unlock() -> void:
	set_process_input(true)

var _power_up

func _init():
	_power_up = preload("res://scripts/power_up.gd").new()

func use_power(idx: int) -> bool:
	return _power_up.activate(idx, board, renderer, _match_resolver)

func _on_ripple_done() -> void:
	pass
