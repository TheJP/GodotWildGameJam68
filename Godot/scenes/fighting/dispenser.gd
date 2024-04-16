extends DropTarget


@onready var ray = $RayCast2D
var item = null


func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_crafting(global_position)


func hover():
	scale = Vector2(1.1, 1.1)


func unhover():
	scale = Vector2(1, 1)


func try_drop(p_item: Node2D) -> bool:
	if item != null:
		return false
	else:
		item = p_item
		item.global_position = global_position
		return true


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
