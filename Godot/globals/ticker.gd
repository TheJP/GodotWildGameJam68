extends Node

var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.start(1)
