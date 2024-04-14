extends Node2D


@onready var item_scene = preload('res://scenes/crafting/item.tscn')


func _ready():
	var item = item_scene.instantiate()
	item.type = Item.Type.COAL
	add_child(item)
	item = item_scene.instantiate()
	item.type = Item.Type.FIRE
	add_child(item)
	item = item_scene.instantiate()
	item.type = Item.Type.HAMMER
	add_child(item)
	item = item_scene.instantiate()
	item.type = Item.Type.TRASH
	add_child(item)
