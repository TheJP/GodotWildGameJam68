extends Node


var tick_time := 1
var timer = Timer.new()


signal game_over()
signal new_game()


func _ready():
	add_child(timer)
	timer.start(tick_time)
	new_game.emit()


func trigger_new_game():
	new_game.emit()


func trigger_game_over():
	game_over.emit()

