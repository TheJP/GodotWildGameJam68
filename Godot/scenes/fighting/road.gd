class_name Road
extends Area2D


var fighter = null


func _ready():
	global_position = Tile.snap_crafting(global_position)
