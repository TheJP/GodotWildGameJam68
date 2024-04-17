class_name Machine
extends Area2D


@export var type: Tile.Type


func _init():
	add_to_group("machine")


func hover():
	pass


func unhover():
	pass


func try_drop(_item: Node2D) -> bool:
	return false


func try_remove() -> bool:
	return false


func destroy():
	queue_free()
