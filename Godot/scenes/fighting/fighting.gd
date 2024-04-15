extends Node2D

func _draw():
	var size = get_viewport_rect().size
	for i in range(int((- size.x) / 64) - 1, int((size.x) / 64) + 1):
		draw_line(Vector2(i * 64, size.y + 100), Vector2(i * 64, -size.y-100), "000000")
	for i in range(int((- size.y) / 64) - 1, int((size.y) / 64) + 1):
		draw_line(Vector2(size.x + 100, i * 64), Vector2(- size.x - 100, i * 64), "000000")
