extends Area2D


func _ready():
	global_position = Tile.snap_crafting(global_position)
