extends Node
## 拖拽交换系统 — 鼠标/触摸 (Godot 自动模拟)

const HC = preload("res://scripts/hex_coord.gd")

var renderer
var board
var game_loop

var _drag_start: Vector2
var _drag_from_hc
var _dragging: bool = false

func setup(rend, brd, gl) -> void:
	renderer = rend
	board = brd
	game_loop = gl

func _input(event: InputEvent) -> void:
	if game_loop.get("locked") == true:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_drag_start = event.position
			_drag_from_hc = _hex_at(event.position)
			_dragging = _drag_from_hc != null
		elif event is InputEventMouseButton and not event.pressed and _dragging:
			_finish_drag(event.position)

func _finish_drag(pos: Vector2) -> void:
	_dragging = false
	var end_hc = _hex_at(pos)
	if end_hc != null and not end_hc.equals(_drag_from_hc):
		var dir = _get_swap_direction(_drag_from_hc, end_hc)
		if dir >= 0:
			var target_hc = _drag_from_hc.neighbor_at(dir)
			if board.is_valid(target_hc):
				game_loop.request_swap(_drag_from_hc, target_hc)
	_drag_from_hc = null

func _hex_at(pos: Vector2) -> HC:
	var local = pos - renderer.global_position
	return HC.from_pixel(local, renderer.hex_size)

func _get_swap_direction(from_hc, to_hc) -> int:
	var delta = Vector2(to_hc.q - from_hc.q, to_hc.r - from_hc.r)
	for i in range(6):
		var dir = HC.NEIGHBOR_DIRS[i]
		if delta.x == dir.x and delta.y == dir.y:
			return i
	var best = -1
	var best_dist = 999.0
	for i in range(6):
		var n = from_hc.neighbor_at(i)
		var dist = abs(n.q - to_hc.q) + abs(n.r - to_hc.r)
		if dist < best_dist:
			best_dist = dist
			best = i
	return best if best_dist <= 2 else -1
