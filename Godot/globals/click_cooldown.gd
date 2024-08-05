extends Node

var cooldown := 0.5
var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true

func try_click_action():
	if timer.is_stopped():
		timer.start(cooldown)
		return true
	else:
		return false
