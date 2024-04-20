extends Node2D


@onready var tilesize = GameParameters.tilesize


func _draw():
	var size = get_viewport_rect().size
	var g = global_position
	for i in range(int((- size.x) / tilesize) - 1, int((size.x) / tilesize) + 1):
		draw_line(Vector2(i * tilesize, size.y + 100) - g, Vector2(i * tilesize, -size.y-100) - g, Color(Color.BLACK, 0.15))
	for i in range(int((- size.y) / tilesize) - 1, int((size.y) / tilesize) + 1):
		draw_line(Vector2(size.x + 100, i * tilesize) - g, Vector2(- size.x - 100, i * tilesize) - g, Color(Color.BLACK, 0.15))
