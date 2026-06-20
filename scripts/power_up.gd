extends Node
## 四道具系统 + UI

const RIPPLE    = 0  # 共振波纹
const SOLIDIFY  = 1  # 圈层固化
const HARMONY   = 2  # 全域谐振
const PURGE     = 3  # 紊乱净化

const HexBoard = preload("res://scripts/hex_board.gd")

var renderer
var board

## 道具库存 [count, count, count, count]
var inventory := [1, 1, 1, 1]
var score: int = 0  # 积分兑换用

signal power_used(power_idx: int)

func setup(rend, brd) -> void:
	renderer = rend
	board = brd

func use_power(idx: int) -> bool:
	if inventory[idx] <= 0:
		return false
	
	inventory[idx] -= 1
	
	match idx:
		RIPPLE: _do_ripple()
		SOLIDIFY: _do_solidify()
		HARMONY: _do_harmony()
		PURGE: _do_purge()
	
	power_used.emit(idx)
	return true

func add_power(idx: int, count: int = 1) -> void:
	inventory[idx] += count

## 共振波纹: 从随机同色碎片出发扩散
func _do_ripple() -> void:
	var cells = board.all_cells()
	if cells.size() == 0: return
	var pick = cells[randi() % cells.size()]
	var neigh = board.valid_neighbors(pick.coord)
	if neigh.size() == 0: return
	var target = neigh[randi() % neigh.size()]
	var t = renderer._tiles.get(pick.coord.to_vector2i())
	if t != null:
		var tw = create_tween()
		tw.tween_property(t, "scale", Vector2(1.5, 1.5), 0.15)
		tw.tween_property(t, "scale", Vector2.ONE, 0.15)
	# 简单视觉反馈后, 由 game_loop 扫描棋盘

## 圈层固化: 将碎片吸附到最近的半成品圈层
func _do_solidify() -> void:
	# ponytail: 简单实现 — 找到最近的空 cell 填充同色
	var empty_coords = []
	for hc in board.all_coords:
		if board.get_cell(hc) == null:
			empty_coords.append(hc)
	if empty_coords.size() == 0: return
	var target = empty_coords[randi() % empty_coords.size()]
	var color = randi() % HexBoard.COLOR_COUNT
	if board.is_valid(target):
		board.set_cell(target, color)
		var tile_scr = preload("res://scripts/tile.gd")
		var t = tile_scr.new()
		t.setup(target, color, renderer.hex_size)
		renderer.add_child(t)
		renderer._tiles[target.to_vector2i()] = t

## 全域谐振: 扫描并激活所有半成品圈层
func _do_harmony() -> void:
	# ponytail: 直接触发完整棋盘扫描，由 game_loop 处理消除
	pass

## 紊乱净化: 清除所有紊乱碎片
func _do_purge() -> void:
	board.clear_all_disorder()
	# 移除视觉上的紊乱碎片
	var to_remove = []
	for key in renderer._tiles:
		var t = renderer._tiles[key]
		if t.is_disorder:
			to_remove.append(key)
	for key in to_remove:
		renderer._tiles[key].queue_free()
		renderer._tiles.erase(key)
	# 触发特效
	var f = get_node_or_null("../ParticleFx")
	if f: f.play_purge_fx()