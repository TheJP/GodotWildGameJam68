extends DropTarget


@onready var ray = $RayCast2D
var item = null


signal hovered()
signal unhovered()
signal received_item()
signal lost_item()


func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)


func try_drop(p_item: Node2D) -> bool:
	if item == null:
		item = p_item
		item.global_position = global_position
		received_item.emit()
		return true
	else:
		return false


func try_dispense_item():
	ray.target_position = Vector2.DOWN * GameParameters.tilesize
	ray.force_raycast_update()
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider is Friendly:
			if !collider.has_item:
				collider.set_item(item)
				item.queue_free()
				item = null


func on_global_ticker_timeout():
	if item != null:
		try_dispense_item()
