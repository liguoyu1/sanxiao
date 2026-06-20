extends RefCounted
## 圈层判定器 — 三角/菱形/六边满环/嵌套

const HC = preload("res://scripts/hex_coord.gd")

const TRIANGLE := 3
const RHOMBUS  := 4
const HEX_RING := 6
const NESTED   := 7

## 匹配结果
class MatchResult:
	var cells: Array = []
	var loop_type: int
	var center
	var score: int
	var is_disorder: bool = false  # 包含紊乱碎片？
	func _init(c, t, ct, s) -> void:
		cells = c; loop_type = t; center = ct; score = s

## 全盘扫描, 返回所有匹配 (按优先级: hex_ring > rhombus > triangle)
static func scan(board) -> Array[MatchResult]:
	var results: Array[MatchResult] = []
	var visited = {}

	# 1. 六边满环 (最高优先级)
	for hc in board.all_coords:
		var key = hc.to_vector2i()
		if visited.has(key): continue
		var hex = _scan_hex_ring(board, hc, visited)
		if hex != null:
			results.append(hex)
			for ch in hex.cells:
				visited[ch.to_vector2i()] = true
			# 嵌套检查
			var nest = _scan_nested(board, hc, visited)
			if nest != null:
				results.append(nest)
				for ch in nest.cells:
					visited[ch.to_vector2i()] = true

	# 2. 菱形
	for hc in board.all_coords:
		var key = hc.to_vector2i()
		if visited.has(key): continue
		var rhom = _scan_rhombus(board, hc, visited)
		if rhom != null:
			results.append(rhom)
			for ch in rhom.cells:
				visited[ch.to_vector2i()] = true

	# 3. 三角
	for hc in board.all_coords:
		var key = hc.to_vector2i()
		if visited.has(key): continue
		var tri = _scan_triangle(board, hc, visited)
		if tri != null:
			results.append(tri)
			for ch in tri.cells:
				visited[ch.to_vector2i()] = true

	return results

## 六边满环: 中心周围 6 个邻居全部同色
static func _scan_hex_ring(board, center, visited) -> MatchResult:
	var c = board.get_cell(center)
	if c == null or c.is_disorder: return null
	var ccolor = c.color
	var ring = center.neighbors()
	for n in ring:
		if not board.is_valid(n): return null
		var nc = board.get_cell(n)
		if nc == null or nc.color != ccolor or nc.is_disorder: return null
		if visited.has(n.to_vector2i()): return null
	return MatchResult.new(ring, HEX_RING, center, 60)

## 嵌套三角: 六边形内部 (中心+2个邻居) 形成的三角
static func _scan_nested(board, center, visited) -> MatchResult:
	var c = board.get_cell(center)
	if c == null or c.is_disorder: return null
	var ccolor = c.color
	var near = center.neighbors()
	for i in range(6):
		if visited.has(near[i].to_vector2i()): continue
		var n1 = near[i]
		var c1 = board.get_cell(n1)
		if c1 == null or c1.color != ccolor or c1.is_disorder: continue
		for j in range(i + 1, 6):
			var n2 = near[j]
			var c2 = board.get_cell(n2)
			if c2 == null or c2.color != ccolor or c2.is_disorder: continue
			if n1.distance_to(n2) <= 1:
				return MatchResult.new([n1, n2, center], NESTED, center, 100)
	return null

## 菱形: 4 cell 平行四边形
static func _scan_rhombus(board, start, visited) -> MatchResult:
	var c = board.get_cell(start)
	if c == null or c.is_disorder: return null
	var ccolor = c.color
	# 三个菱形模式
	var patterns = [
		[HC.new(0,0), HC.new(1,0), HC.new(0,-1), HC.new(1,-1)],
		[HC.new(0,0), HC.new(1,0), HC.new(-1,1), HC.new(0,1)],
		[HC.new(0,0), HC.new(0,-1), HC.new(-1,1), HC.new(-1,0)],
	]
	for pat in patterns:
		var cells: Array = []
		var ok = true
		for d in pat:
			var hc = HC.new(start.q + d.q, start.r + d.r)
			if not board.is_valid(hc): ok = false; break
			var cell = board.get_cell(hc)
			if cell == null or cell.color != ccolor or cell.is_disorder: ok = false; break
			cells.append(hc)
		if ok and cells.size() == 4:
			return MatchResult.new(cells, RHOMBUS, cells[0], 30)
	return null

## 三角
static func _scan_triangle(board, hc, visited) -> MatchResult:
	var c = board.get_cell(hc)
	if c == null or c.is_disorder: return null
	var ccolor = c.color
	var neigh = board.valid_neighbors(hc)
	for i in range(neigh.size()):
		var n1 = neigh[i]
		var c1 = board.get_cell(n1)
		if c1 == null or c1.color != ccolor or c1.is_disorder: continue
		for j in range(i + 1, neigh.size()):
			var n2 = neigh[j]
			var c2 = board.get_cell(n2)
			if c2 == null or c2.color != ccolor or c2.is_disorder: continue
			if n1.distance_to(n2) <= 1:
				return MatchResult.new([hc, n1, n2], TRIANGLE, hc, 10)
	return null