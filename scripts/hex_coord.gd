extends RefCounted
## 轴向六边形坐标系统 (q, r)
class_name HexCoord

## 轴向坐标 q (列) 和 r (行)
var q: int
var r: int

## 六边形 6 个邻居方向 (轴向坐标偏移)
## 方向: 右、右上、左上、左、左下、右下
const NEIGHBOR_DIRS: Array[Vector2i] = [
	Vector2i(1,  0),   Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0),   Vector2i(-1, 1), Vector2i(0,  1),
]

func _init(p_q: int = 0, p_r: int = 0) -> void:
	q = p_q
	r = p_r

func to_vector2i() -> Vector2i:
	return Vector2i(q, r)

## 获取所有 6 个邻居坐标
func neighbors() -> Array[HexCoord]:
	var result: Array[HexCoord] = []
	for dir in NEIGHBOR_DIRS:
		result.append(HexCoord.new(q + dir.x, r + dir.y))
	return result

## 获取指定方向索引上的邻居
func neighbor_at(dir_index: int) -> HexCoord:
	var dir := NEIGHBOR_DIRS[dir_index]
	return HexCoord.new(q + dir.x, r + dir.y)

## 六边形曼哈顿距离 (axial → cube distance)
func distance_to(other: HexCoord) -> int:
	var dq := other.q - q
	var dr := other.r - r
	return maxi(maxi(abs(dq), abs(dr)), abs(dq + dr))

## 比较两个坐标是否相等
func equals(other) -> bool:
	return q == other.q and r == other.r

## 转换为屏幕像素坐标 (flat-top 扁平六边形)
## hex_size: 六边形中心到顶点距离
func to_pixel(hex_size: float, offset: Vector2 = Vector2.ZERO) -> Vector2:
	var x := hex_size * (sqrt(3.0) * q + sqrt(3.0) / 2.0 * r)
	var y := hex_size * (3.0 / 2.0 * r)
	return Vector2(x, y) + offset

## 从像素坐标反推最近的六边形坐标
static func from_pixel(pixel: Vector2, hex_size: float, offset: Vector2 = Vector2.ZERO) -> HexCoord:
	var local := pixel - offset
	var q_float := (sqrt(3.0) / 3.0 * local.x - 1.0 / 3.0 * local.y) / hex_size
	var r_float := (2.0 / 3.0 * local.y) / hex_size
	return _hex_round(q_float, r_float)

## 浮点轴向坐标取整到最近的 hex (cube rounding)
static func _hex_round(q_float: float, r_float: float) -> HexCoord:
	var s_float: float = -q_float - r_float
	var q_round: int = roundi(q_float)
	var r_round: int = roundi(r_float)
	var s_round: int = roundi(s_float)
	var q_diff: float = abs(float(q_round) - q_float)
	var r_diff: float = abs(float(r_round) - r_float)
	var s_diff: float = abs(float(s_round) - s_float)
	if q_diff > r_diff and q_diff > s_diff:
		q_round = -r_round - s_round
	elif r_diff > s_diff:
		r_round = -q_round - s_round
	return HexCoord.new(q_round, r_round)

## 半径内所有坐标
static func all_in_radius(radius: int) -> Array[HexCoord]:
	var result: Array[HexCoord] = []
	for q in range(-radius, radius + 1):
		for r in range(-radius, radius + 1):
			if abs(q + r) <= radius:
				result.append(HexCoord.new(q, r))
	return result

func _to_string() -> String:
	return "HexCoord(%d, %d)" % [q, r]
