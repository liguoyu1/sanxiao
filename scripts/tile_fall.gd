extends Node
## 碎片掉落补充 — 空 cell 从上方填充

const HC = preload("res://scripts/hex_coord.gd")
const HexBoard = preload("res://scripts/hex_board.gd")
const BoardRenderer = preload("res://scripts/board_renderer.gd")

var renderer: BoardRenderer
var board: HexBoard

func setup(rend: BoardRenderer, brd: HexBoard) -> void:
	renderer = rend
	board = brd

## 重力下落 + 顶部补充新碎片
func apply_fall() -> void:
	# 按列处理：每列的 r 从大到小 (从下到上)
	for q in range(-HexBoard.BOARD_RADIUS, HexBoard.BOARD_RADIUS + 1):
		var col = board.column_coords(q)
		# 从底部向上遍历
		for i in range(col.size() - 1, -1, -1):
			var hc = col[i]
			if board.get_cell(hc) != null:
				continue
			
			# 向上找最近的 non-empty cell
			var found_hc = null
			for j in range(i - 1, -1, -1):
				var upper = col[j]
				if board.get_cell(upper) != null:
					found_hc = upper
					break
			
			if found_hc != null:
				var cell = board.get_cell(found_hc)
				board.set_cell(hc, cell.color)
				board.remove_cell(found_hc)
				# 渲染: 移动 sprite 到新位置
				var t = renderer._tiles.get(found_hc.to_vector2i())
				if t != null:
					renderer._tiles.erase(found_hc.to_vector2i())
					renderer._tiles[hc.to_vector2i()] = t
					t.hex_coord = hc
					# ponytail: 简单位置设置, tween 在 animate_fall 已处理
					t.position = hc.to_pixel(renderer.hex_size)
			else:
				# 顶部生成新碎片
				var new_color = randi() % HexBoard.COLOR_COUNT
				board.set_cell(hc, new_color)
				var t = renderer._tiles.get(hc.to_vector2i())
				if t == null:
					# 新生成
					var tile_script = preload("res://scripts/tile.gd")
					var tile = tile_script.new()
					tile.setup(hc, new_color, renderer.hex_size)
					renderer.add_child(tile)
					renderer._tiles[hc.to_vector2i()] = tile
					# 从上方动画
					tile.position.y -= renderer.hex_size * 2.0
				else:
					t.color_index = new_color
					t.redraw()
					# 从上方动画
					t.position.y -= renderer.hex_size * 2.0
				
				# 掉落动画
				var tw = create_tween()
				var target_pos = hc.to_pixel(renderer.hex_size)
				var target_t = renderer._tiles.get(hc.to_vector2i())
				tw.tween_property(target_t, "position", target_pos, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)