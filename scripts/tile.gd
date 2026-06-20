extends Sprite2D
## 碎片渲染 — 圆形色块 Sprite2D

const HC = preload("res://scripts/hex_coord.gd")

## 当前所在坐标
var hex_coord
## 当前颜色
var color_index: int = 0
## 被选中高亮
var selected: bool = false
## 是否为紊乱碎片
var is_disorder: bool = false

func setup(hc, color: int, hex_size: float) -> void:
	hex_coord = hc
	color_index = color
	position = hc.to_pixel(hex_size)
	redraw()

## 重绘圆形色块 (生成 1×1 白色 texture + modulate)
func redraw() -> void:
	var s: float = 28.0  # 半径
	var img = Image.create(int(s * 2), int(s * 2), false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	# 画圆 mask
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var dx = x - s
			var dy = y - s
			if dx * dx + dy * dy > s * s:
				img.set_pixel(x, y, Color.TRANSPARENT)
	var tex = ImageTexture.create_from_image(img)
	texture = tex
	modulate = _get_color()
	scale = Vector2.ONE  # 大小由 texture 决定
	centered = false
	offset = Vector2(-s, -s)  # 居中

func _get_color() -> Color:
	if is_disorder:
		return Color(0.4, 0.35, 0.3, 1.0)  # 紊乱: 灰色
	var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.MAGENTA]
	if color_index >= 0 and color_index < colors.size():
		return colors[color_index]
	return Color.WHITE

func set_disorder(d: bool) -> void:
	is_disorder = d
	redraw()

func set_selected(s: bool) -> void:
	selected = s
	scale = Vector2(1.15, 1.15) if s else Vector2.ONE

func _to_string() -> String:
	return "Tile(%s, c=%d)" % [hex_coord, color_index]