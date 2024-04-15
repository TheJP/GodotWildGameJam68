class_name Spawner
extends DropTarget


@export var spawn_type: Item.Type
var item = null
@onready var item_scene = preload('res://scenes/crafting/item.tscn')


func _ready():
	Ticker.timer.timeout.connect(_on_global_ticker_timeout)
	global_position = global_position.snapped(Vector2.ONE * GameParameters.craft_tilesize)
	global_position += Vector2.ONE * (GameParameters.craft_tilesize * 0.5)


func hover():
	scale = Vector2(1.1, 1.1)


func unhover():
	scale = Vector2(1, 1)


func try_remove() -> bool:
	if item == null:
		push_warning('try_remove() called on empty spawner')
		return true
	else:
		item = null
		return true


func _on_global_ticker_timeout():
	if item == null:
		item = item_scene.instantiate()
		item.type = spawn_type
		item.container = self
		add_child(item)
		item.position = Vector2(0, 0)
