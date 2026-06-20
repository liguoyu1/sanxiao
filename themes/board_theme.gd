extends Resource
# ponytail: BoardTheme class_name is in theme_data.gd

@export var tile_colors: Array[Color] = [
	Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.MAGENTA,
]
@export var background_color: Color = Color(0.1, 0.1, 0.15, 1.0)
@export var grid_line_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var grid_line_width: float = 1.5

func get_tile_color(index: int) -> Color:
	if index >= 0 and index < tile_colors.size():
		return tile_colors[index]
	return Color.WHITE