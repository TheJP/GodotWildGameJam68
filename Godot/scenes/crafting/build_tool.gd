extends Node2D


@export var type: Tile.Type


func _ready():
	$Sprite2D.texture = Tile.sprites[type]


func _input(event):
	if event is InputEventMouseMotion:
		position = event.position
