extends Node2D
## 棋盘渲染器 — 绘制六边形网格 + 管理碎片 Sprite

const HC = preload("res://scripts/hex_coord.gd")
const Tile = preload("res://scripts/tile.gd")

var board  # HexBoard
var _tiles: Dictionary = {}

@export var hex_size: float = 40.0
@export var line_color := Color(0.3, 0.3, 0.3, 0.5)
@export var line_width: float = 1.5

func initialize(brd) -> void:
	board = brd
	_draw_all_tiles()

func _draw_all_tiles() -> void:
	for hc in board.all_coords:
		var cell = board.get_cell(hc)
		if cell == null:
			continue
		_spawn_tile(hc, cell.color)

func _spawn_tile(hc, color: int):
	var t = Tile.new()
	t.setup(hc, color, hex_size)
	add_child(t)
	_tiles[hc.to_vector2i()] = t

func remove_tile(hc):
	var key = hc.to_vector2i()
	if _tiles.has(key):
		_tiles[key].queue_free()
		_tiles.erase(key)

func animate_swap(hc1, hc2):
	var t1 = _tiles.get(hc1.to_vector2i())
	var t2 = _tiles.get(hc2.to_vector2i())
	if t1 == null or t2 == null:
		return
	var pos1 = t1.position
	var pos2 = t2.position
	var tw = create_tween().set_parallel(true)
	tw.tween_property(t1, "position", pos2, 0.25).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(t2, "position", pos1, 0.25).set_ease(Tween.EASE_IN_OUT)

func animate_shake(hc):
	var t = _tiles.get(hc.to_vector2i())
	if t == null:
		return
	var orig = t.position
	var tw = create_tween()
	tw.tween_property(t, "position:x", orig.x + 6, 0.05)
	tw.tween_property(t, "position:x", orig.x - 6, 0.05)
	tw.tween_property(t, "position:x", orig.x, 0.05)

func _draw() -> void:
	if board == null:
		return
	for hc in board.all_coords:
		var center = hc.to_pixel(hex_size)
		var verts = PackedVector2Array()
		for i in range(6):
			var angle = PI / 6 + PI / 3 * i
			verts.append(center + Vector2(cos(angle), sin(angle)) * hex_size)
		verts.append(verts[0])  # close loop
		draw_polyline(verts, line_color, line_width)

func clear() -> void:
	for t in _tiles.values():
		t.queue_free()
	_tiles.clear()
	board = null