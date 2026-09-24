extends Node2D

var map_size: Vector2i = Vector2i(20, 20)
var is_active: bool = true

func _draw() -> void:
	if not is_active:
		return
		
	var cell_size = 64
	var line_color = Color(1.0, 1.0, 1.0, 0.15)
	
	for x in range(map_size.x + 1):
		draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, map_size.y * cell_size), line_color, 2.0)
		
	for y in range(map_size.y + 1):
		draw_line(Vector2(0, y * cell_size), Vector2(map_size.x * cell_size, y * cell_size), line_color, 2.0)
