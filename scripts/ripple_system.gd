extends Node
## 波纹共振系统 — 全棋盘同色扩散 + 自动补全

const HC = preload("res://scripts/hex_coord.gd")
const LD = preload("res://scripts/loop_detector.gd")

var renderer
var board

signal ripple_completed(new_matches)  # 波纹触发的新的匹配

func setup(rend, brd) -> void:
	renderer = rend
	board = brd

## 从匹配中心触发共振波纹
func trigger_ripple(matches: Array) -> void:
	var centers = []
	for m in matches:
		if m.center != null:
			centers.append(m.center)
	
	var touched = {}
	
	# BFS 沿同色碎片扩散
	var queue = []
	for c in centers:
		var cell = board.get_cell(c)
		if cell != null and not cell.is_disorder:
			queue.append({ "hc": c, "color": cell.color, "dist": 0 })
			touched[c.to_vector2i()] = true
	
	while queue.size() > 0:
		var cur = queue.pop_front()
		var neigh = cur.hc.neighbors()
		for n in neigh:
			var key = n.to_vector2i()
			if touched.has(key): continue
			if not board.is_valid(n): continue
			var cell = board.get_cell(n)
			if cell == null: continue
			if cell.is_disorder: continue  # 紊乱阻挡波纹
			if cell.color != cur.color and cell.color != -1: continue
			touched[key] = true
			queue.append({ "hc": n, "color": cur.color, "dist": cur.dist + 1 })
	
	# 震动的碎片: 波纹经过的碎片闪烁（视觉暂不处理）
	# ponytail: 简单闪烁效果，复杂动画后面加
	for key in touched:
		var hc = HC.new(key.x, key.y)
		var t = renderer._tiles.get(key)
		if t != null:
			var tw = create_tween()
			tw.tween_property(t, "scale", Vector2(1.3, 1.3), 0.1)
			tw.tween_property(t, "scale", Vector2.ONE, 0.1)
	
	# 然后扫描棋盘看是否有新的匹配 (波纹扩散后自动补全)
	var new_matches = LD.scan(board)
	if new_matches.size() > 0:
		ripple_completed.emit(new_matches)