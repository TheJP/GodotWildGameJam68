class_name Pipe
extends DropTarget


var item = null


func _ready():
	global_position = global_position.snapped(Vector2.ONE * GameParameters.craft_tilesize)
	global_position += Vector2.ONE * (GameParameters.craft_tilesize * 0.5)


func hover():
	scale = Vector2(1.1, 1.1)


func unhover():
	scale = Vector2(1, 1)


func try_drop(p_item: Node2D) -> bool:
	if item != null:
		return false
	else:
		item = p_item
		item.global_position = global_position
		return true


func try_remove() -> bool:
	if item == null:
		push_warning('try_remove() called on empty pipe')
		return true
	else:
		item = null
		return true