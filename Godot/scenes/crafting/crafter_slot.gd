extends DropTarget


var item = null
var is_crafting = false


signal hovered()
signal unhovered()
signal received_item()
signal lost_item()


func hover():
	hovered.emit()


func unhover():
	unhovered.emit()


func try_drop(p_item: Node2D) -> bool:
	if item == null:
		item = p_item
		item.global_position = global_position
		received_item.emit()
		return true
	else:
		return false


func try_start_remove() -> bool:
	return not is_crafting


func remove_item():
	item = null
	lost_item.emit()


func crafted_item(p_item: Node2D):
	if item != null:
		item.queue_free()
	item = p_item
	if item != null:
		item.container = self
