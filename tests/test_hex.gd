extends SceneTree

const HexCoord = preload("res://scripts/hex_coord.gd")
const HexBoard = preload("res://scripts/hex_board.gd")

func _initialize() -> void:
	var failed := false

	var center = HexCoord.new(0, 0)
	var neigh = center.neighbors()
	if neigh.size() != 6:
		failed = true; printerr("邻居数错误: %d" % neigh.size())
	print("邻居数: %d — %s" % [neigh.size(), "✓" if neigh.size() == 6 else "✗"])

	var expected = [HexCoord.new(1,0), HexCoord.new(1,-1), HexCoord.new(0,-1), HexCoord.new(-1,0), HexCoord.new(-1,1), HexCoord.new(0,1)]
	for i in 6:
		if neigh[i].q != expected[i].q or neigh[i].r != expected[i].r:
			failed = true; printerr("邻居 %d 方向错误" % i)
	if not failed: print("邻居方向: ✓")

	var a = HexCoord.new(0, 0)
	var b = HexCoord.new(2, -1)
	if a.distance_to(b) != 2:
		failed = true; printerr("距离错误: %d" % a.distance_to(b))
	print("距离: %d — %s" % [a.distance_to(b), "✓" if a.distance_to(b) == 2 else "✗"])

	var hex_size := 40.0
	var orig = HexCoord.new(2, -1)
	var pixel = orig.to_pixel(hex_size)
	var back = HexCoord.from_pixel(pixel, hex_size)
	if not back.equals(orig):
		failed = true; printerr("像素往返失败: %s→%s" % [orig, back])
	print("像素往返: ✓" if back.equals(orig) else "✗")

	var all_c = HexCoord.all_in_radius(3)
	if all_c.size() != 37:
		failed = true; printerr("cells 数错误: %d" % all_c.size())
	print("cells: %d — %s" % [all_c.size(), "✓" if all_c.size() == 37 else "✗"])

	var board = HexBoard.new()
	board.initialize()
	if board.cell_count() != 37:
		failed = true; printerr("棋盘初始化错误: %d" % board.cell_count())
	print("棋盘 cells: %d — %s" % [board.cell_count(), "✓" if board.cell_count() == 37 else "✗"])

	if not board.is_valid(HexCoord.new(0, 0)):
		failed = true; printerr("中心应合法")
	if board.is_valid(HexCoord.new(5, 0)):
		failed = true; printerr("半径外应非法")
	print("坐标合法性: ✓")

	var oc = board.get_cell(HexCoord.new(0, 0))
	if oc == null:
		failed = true; printerr("中心 cell 不应为 null")
	else:
		var c = oc.color
		board.remove_cell(HexCoord.new(0, 0))
		if board.get_cell(HexCoord.new(0, 0)) != null:
			failed = true; printerr("移除后应为 null")
		board.set_cell(HexCoord.new(0, 0), c)
		if board.get_cell(HexCoord.new(0, 0)) == null:
			failed = true; printerr("重设后不应为 null")
	print("移除/设置: ✓" if oc != null else "✗")

	var corner = HexCoord.new(3, -3)
	var vn = board.valid_neighbors(corner)
	if vn.size() >= 6 or vn.size() == 0:
		failed = true; printerr("边界邻居数错误: %d" % vn.size())
	print("边界邻居: %d — ✓" % vn.size())

	quit(1 if failed else 0)
