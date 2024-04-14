extends DropTarget


var item = null


signal hovered()
signal unhovered()
signal received_item()


func hover():
	hovered.emit()


func unhover():
	unhovered.emit()


func try_drop(p_item: Node2D):
	if item == null:
		item = p_item
		item.global_position = global_position
		received_item.emit()
		return true
	else:
		return false


func try_start_remove() -> bool:
	return true # TODO: return false after crafting started


func remove_item():
	item = null
