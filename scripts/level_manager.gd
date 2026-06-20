extends Node
## 关卡管理 — 加载/推进/解锁/数据

const LD = preload("res://scripts/level_data.gd")

## 当前关卡 ID (1-based)
var current_level: int = 1
## 最高解锁关卡
var max_unlocked: int = 1

signal level_changed(level_data: LD)
signal level_completed(stars: int)
signal game_over()

## 生成 50 关数据 (可在游戏初始化时调用生成 .tres 文件)
func generate_all_levels() -> void:
	# 经典闯关 35 关
	for i in range(1, 36):
		var lv = LD.new()
		lv.level_id = i
		lv.mode = LD.Mode.CLASSIC
		lv.display_name = "经典 %d" % i
		lv.max_steps = max(15, 35 - i)  # 越往后步数越少
		lv.target_score = 200 + i * 50
		if i > 20: lv.target_loops = i - 20  # 后期加入圈层目标
		ResourceSaver.save(lv, "res://scenes/levels/level_%03d.tres" % i)
	
	# 限时共振 8 关
	for i in range(36, 44):
		var lv = LD.new()
		lv.level_id = i
		lv.mode = LD.Mode.TIMED
		lv.display_name = "限时 %d" % (i - 35)
		lv.time_limit = 60.0 - (i - 35) * 2.5  # 60s → 40s
		ResourceSaver.save(lv, "res://scenes/levels/level_%03d.tres" % i)
	
	# 圈层解谜 7 关
	for i in range(44, 51):
		var lv = LD.new()
		lv.level_id = i
		lv.mode = LD.Mode.PUZZLE
		lv.display_name = "解谜 %d" % (i - 43)
		lv.max_steps = 8 - (i - 44)  # 8 → 2 步
		ResourceSaver.save(lv, "res://scenes/levels/level_%03d.tres" % i)

func get_level(id: int) -> LD:
	var path = "res://scenes/levels/level_%03d.tres" % id
	if ResourceLoader.exists(path):
		return load(path) as LD
	return null

func advance() -> void:
	var next = current_level + 1
	var path = "res://scenes/levels/level_%03d.tres" % next
	if ResourceLoader.exists(path):
		current_level = next
		if next > max_unlocked:
			max_unlocked = next
		level_changed.emit(get_level(next))
	else:
		game_over.emit()

func restart_level() -> void:
	level_changed.emit(get_level(current_level))