extends RefCounted
## 棋盘数据模型 — 管理 7×7 蜂巢棋盘状态
class_name HexBoard

const HC = preload("res://scripts/hex_coord.gd")
const BOARD_RADIUS := 3
const COLOR_COUNT := 5

class CellInfo:
	var color: int
	var coord
	var is_disorder: bool = false
	func _init(p_coord, p_color: int, p_disorder := false) -> void:
		coord = p_coord
		color = p_color
		is_disorder = p_disorder

var _cells: Dictionary = {}
var all_coords = []

func _init() -> void:
	all_coords = HC.all_in_radius(BOARD_RADIUS)

func initialize() -> void:
	_cells.clear()
	for hc in all_coords:
		_cells[hc.to_vector2i()] = CellInfo.new(hc, randi() % COLOR_COUNT)
	_ensure_seed_loop()

func _ensure_seed_loop() -> void:
	var color = randi() % COLOR_COUNT
	for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1)]:
		var hc = HC.new(d.x, d.y)
		if _cells.has(hc.to_vector2i()):
			_cells[hc.to_vector2i()].color = color

func get_cell(hc) -> CellInfo:
	return _cells.get(hc.to_vector2i(), null)

func is_valid(hc) -> bool:
	return abs(hc.q + hc.r) <= BOARD_RADIUS and abs(hc.q) <= BOARD_RADIUS and abs(hc.r) <= BOARD_RADIUS

func valid_neighbors(hc):
	var res = []
	for n in hc.neighbors():
		if is_valid(n):
			res.append(n)
	return res

func remove_cell(hc) -> void:
	_cells.erase(hc.to_vector2i())

func set_cell(hc, color: int) -> void:
	_cells[hc.to_vector2i()] = CellInfo.new(hc, color)

func column_coords(q: int):
	var res = []
	for r in range(-BOARD_RADIUS, BOARD_RADIUS + 1):
		var hc = HC.new(q, r)
		if is_valid(hc):
			res.append(hc)
	return res

func cell_count() -> int:
	return _cells.size()

func all_cells() -> Array:
	return _cells.values()

## 在棋盘空白位置随机刷一个紊乱碎片
func spawn_disorder() -> bool:
	var empties = []
	for hc in all_coords:
		if not _cells.has(hc.to_vector2i()):
			empties.append(hc)
	if empties.size() == 0:
		return false
	var idx = randi() % empties.size()
	var hc = empties[idx]
	_cells[hc.to_vector2i()] = CellInfo.new(hc, -1, true)
	return true

## 清除指定位置上的紊乱碎片
func clear_disorder(hc) -> bool:
	var key = hc.to_vector2i()
	if not _cells.has(key):
		return false
	if not _cells[key].is_disorder:
		return false
	_cells.erase(key)
	return true

## 清除所有紊乱碎片 (净化道具)
func clear_all_disorder() -> int:
	var count = 0
	for hc in all_coords:
		var key = hc.to_vector2i()
		if _cells.has(key) and _cells[key].is_disorder:
			_cells.erase(key)
			count += 1
	return count

func get_disorder_count() -> int:
	var n = 0
	for hc in all_coords:
		var key = hc.to_vector2i()
		if _cells.has(key) and _cells[key].is_disorder:
			n += 1
	return n

func duplicate():
	var board = HexBoard.new()
	for key in _cells:
		var c = _cells[key]
		board._cells[key] = CellInfo.new(c.coord, c.color)
	return board