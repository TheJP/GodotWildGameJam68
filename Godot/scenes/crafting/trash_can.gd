extends DropTarget


func hover():
	scale = Vector2(1.2, 1.2)


func unhover():
	scale = Vector2(1, 1)


func try_drop(item: Node2D):
	item.queue_free()
	return true
