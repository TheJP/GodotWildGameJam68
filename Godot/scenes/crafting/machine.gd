class_name Machine
extends DropTarget


@export var type: Tile.Type


func _init():
	add_to_group("machine")

func destroy():
	queue_free()
