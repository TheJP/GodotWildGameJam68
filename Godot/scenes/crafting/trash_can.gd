extends DropTarget


func _ready():
	global_position = global_position.snapped(Vector2.ONE * GameParameters.craft_tilesize)
	global_position += Vector2.ONE * (GameParameters.craft_tilesize * 0.5)


func hover():
	scale = Vector2(1.2, 1.2)


func unhover():
	scale = Vector2(1, 1)


func try_drop(item: Node2D) -> bool:
	item.global_position = global_position
	var tween := create_tween().tween_property(item, "scale", Vector2.ZERO, Ticker.tick_time)
	tween.finished.connect(item.queue_free)
	return true
