extends Area2D


func _ready():
	global_position = Tile.snap_crafting(global_position, Vector2i(3, 3))
