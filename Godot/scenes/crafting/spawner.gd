class_name Spawner
extends Machine


@export var spawn_type: Item.Type
var item = null
@onready var item_scene = preload('res://scenes/crafting/item.tscn')
var spawn_rate = 4
var counter = 3

func _ready():
	Game.timer.timeout.connect(_on_global_ticker_timeout)
	global_position = Tile.snap_crafting(global_position)
	if randi() % 2:
		spawn_type = Item.Type.WOOD
	else:
		spawn_type = Item.Type.STONE

func hover():
	scale = Vector2(1.1, 1.1)


func unhover():
	scale = Vector2(1, 1)


func destroy():
	if item != null:
		item.queue_free()
	queue_free()


func try_remove() -> bool:
	if item == null:
		push_warning('try_remove() called on empty spawner')
		return true
	else:
		item = null
		return true


func _on_global_ticker_timeout():
	counter += 1
	if counter == spawn_rate:
		if item == null:
			item = item_scene.instantiate()
			item.type = spawn_type
			item.container = self
			get_parent().add_child(item)
			item.global_position = global_position + Vector2.UP * GameParameters.craft_tilesize
			create_tween().tween_property(item, "global_position", global_position, 1.0 / item.animation_speed)
		counter = 0
