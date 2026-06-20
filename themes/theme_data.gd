extends Resource
## 棋盘主题配置

class_name BoardTheme

@export var name: String = "默认"
@export var bg_color: Color = Color(0.1, 0.1, 0.15)
@export var grid_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var tile_colors: Array[Color] = [
	Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.MAGENTA,
]
@export var fx_color: Color = Color(1, 0.8, 0.2)
@export var ripple_color: Color = Color(1, 1, 1, 0.3)

func get_tile_color(i: int) -> Color:
	if i >= 0 and i < tile_colors.size():
		return tile_colors[i]
	return Color.WHITE