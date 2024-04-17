class_name Pipe
extends Machine


var item = null


func _ready():
	global_position = Tile.snap_crafting(global_position)


func hover():
	scale = Vector2(1.1, 1.1)


func unhover():
	scale = Vector2(1, 1)


func destroy():
	if item != null:
		item.queue_free()
	queue_free()


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
