class_name LevelData
extends Resource

## 关卡定义资源
## 经典闯关: steps, target_score, target_loops
## 限时共振: time_limit (秒)
## 圈层解谜: fixed_board (Array[Vector2i->color]), steps

enum Mode { CLASSIC, TIMED, PUZZLE }

@export var level_id: int = 1
@export var mode: Mode = Mode.CLASSIC
@export var display_name: String = ""

# Classic / Puzzle
@export var max_steps: int = 30
# Classic
@export var target_score: int = 500
@export var target_loops: int = 0  # 0 = disabled

# Timed
@export var time_limit: float = 60.0

# Puzzle: board state encoding
# Array of [q, r, color] or empty for random fill
@export var fixed_cells: Array = []

func get_mode_name() -> String:
	match mode:
		Mode.CLASSIC: return "经典闯关"
		Mode.TIMED: return "限时共振"
		Mode.PUZZLE: return "圈层解谜"
	return ""

func get_description() -> String:
	match mode:
		Mode.CLASSIC:
			var parts = []
			if target_score > 0: parts.append("积分 %d" % target_score)
			if target_loops > 0: parts.append("圈层 %d" % target_loops)
			parts.append("步数 %d" % max_steps)
			return " / ".join(parts)
		Mode.TIMED:
			return "倒计时 %d 秒" % int(time_limit)
		Mode.PUZZLE:
			return "步数 %d · 固定布局" % max_steps
		_: return ""