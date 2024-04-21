extends Node

var factory_health = 100
var progress = 0
var times_spawned = 1
var highscore = 0
signal update_health_bar

var reachedTransition = false

func new_game():
	factory_health = 100
	progress = 0
	times_spawned = 0


func update_health(amount):
	factory_health += amount
	
	update_health_bar.emit()
	if factory_health <= 0:
		await get_tree().create_timer(1).timeout
		AudioController.get_player("GameOverSound").play()
		get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

func _process(_delta):
	if reachedTransition:
		if AudioController.get_player("Transition").playing == false:
			if AudioController.get_player("EndgameLoop").playing == false:
				AudioController.get_player("EndgameLoop").play()
	else:
		if progress == 1:
			AudioController.get_player("Level1Loop").stream.set_loop_mode(0)
			if AudioController.get_player("Level1Loop").playing == false:
				if AudioController.get_player("Level2Loop").playing == false:
					AudioController.get_player("Level2Loop").play()
		elif progress == 2:
			AudioController.get_player("Level1Loop").stream.set_loop_mode(0)
			AudioController.get_player("Level2Loop").stream.set_loop_mode(0)
			if AudioController.get_player("Level1Loop").playing == false:
				if AudioController.get_player("Level2Loop").playing == false:
					if AudioController.get_player("Level3Loop").playing == false:
						AudioController.get_player("Level3Loop").play()
		elif progress == 3:
			AudioController.get_player("Level1Loop").stream.set_loop_mode(0)
			AudioController.get_player("Level2Loop").stream.set_loop_mode(0)
			AudioController.get_player("Level3Loop").stream.set_loop_mode(0)
			if AudioController.get_player("Level1Loop").playing == false:
				if AudioController.get_player("Level2Loop").playing == false:
					if AudioController.get_player("Level3Loop").playing == false:
						if AudioController.get_player("Level4Loop").playing == false:
							AudioController.get_player("Level4Loop").play()
		elif progress == 4:
			AudioController.get_player("Level1Loop").stream.set_loop_mode(0)
			AudioController.get_player("Level2Loop").stream.set_loop_mode(0)
			AudioController.get_player("Level3Loop").stream.set_loop_mode(0)
			AudioController.get_player("Level4Loop").stream.set_loop_mode(0)
			if AudioController.get_player("Level1Loop").playing == false:
				if AudioController.get_player("Level2Loop").playing == false:
					if AudioController.get_player("Level3Loop").playing == false:
						if AudioController.get_player("Level4Loop").playing == false:
							reachedTransition = true
							AudioController.get_player("Transition").stream.set_loop_mode(0)
							AudioController.get_player("Transition").play()
						
						
func set_progress_level(level):
	progress = level

