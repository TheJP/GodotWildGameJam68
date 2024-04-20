extends Control


func _ready():
	visible = GameParameters.is_tutorial
	if not GameParameters.is_tutorial:
		queue_free()
