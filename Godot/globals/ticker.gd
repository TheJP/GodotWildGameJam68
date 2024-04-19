extends Node


var tick_time := 1
var timer = Timer.new()


func _ready():
	add_child(timer)
	timer.start(tick_time)
