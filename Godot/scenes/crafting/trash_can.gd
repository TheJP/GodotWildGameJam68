class_name TrashCan
extends Machine


func _ready():
	global_position = Tile.snap_crafting(global_position)


func hover():
	scale = Vector2(1.2, 1.2)


func unhover():
	scale = Vector2(1, 1)


func try_drop(item: Node2D) -> bool:
	item.global_position = global_position
	var tween := create_tween().tween_property(item, "scale", Vector2.ZERO, Ticker.tick_time)
	tween.finished.connect(item.queue_free)
	AudioController.get_player("ItemTrashSound").play()
	return true


func destroy():
	queue_free()
	AudioController.get_player("FactoryPartRemoveSound").play()
