class_name DropTarget
extends Area2D


func _init():
	add_to_group("drop_target")


func hover():
	pass


func unhover():
	pass


func try_drop(_item: Node2D) -> bool:
	return false


func try_remove() -> bool:
	return false
