extends Node
## 消除执行器 — 使用 LoopDetector.scan()

const HC = preload("res://scripts/hex_coord.gd")
const LD = preload("res://scripts/loop_detector.gd")

var renderer
var board
var score: int = 0

signal match_resolved(matched)

func setup(rend, brd) -> void:
	renderer = rend
	board = brd

func resolve() -> Array:
	var matches = LD.scan(board)
	if matches.size() == 0:
		return []
	for m in matches:
		for hc in m.cells:
			renderer.remove_tile(hc)
			board.remove_cell(hc)
			score += m.score
	match_resolved.emit(matches)
	return matches

static func would_match(board_src, hc1, hc2) -> bool:
	var b = board_src.duplicate()
	var c1 = b.get_cell(hc1)
	var c2 = b.get_cell(hc2)
	if c1 == null or c2 == null: return false
	var tmp = c1.color
	c1.color = c2.color
	c2.color = tmp
	return LD.scan(b).size() > 0