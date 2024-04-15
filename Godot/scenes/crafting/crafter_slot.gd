class_name CrafterSlot
extends DropTarget


var item = null
var is_crafting := false # If true: prevents dragging item out.
var is_waiting_for_craft := false # If true: prevents item flowing off into a pipe.


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
		is_waiting_for_craft = true
		item.global_position = global_position
		received_item.emit()
		return true
	else:
		return false


func try_remove() -> bool:
	if is_crafting:
		return false

	item = null
	is_waiting_for_craft = false
	lost_item.emit()
	return true


func crafted_item(p_item: Node2D):
	is_waiting_for_craft = false
	if item == p_item:
		return
	if item != null:
		item.queue_free()
	item = p_item
	if item != null:
		item.container = self
