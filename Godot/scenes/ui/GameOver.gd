extends CanvasLayer


var _hovered = null


func _ready():
	AudioController.get_player('CalmMenuLoop').play()
	var score = GlobalStats.times_spawned
	var highscore = GlobalStats.highscore
	var is_new_highscore: bool = score > highscore
	%Score.text = str(score)
	%PreviousHighscore.text = str(highscore)
	%NewHighscore.visible = is_new_highscore
	%HighscoreLabel.visible = not is_new_highscore
	%PreviousHighscoreLabel.visible = is_new_highscore
	if is_new_highscore:
		GlobalStats.set_highscore(score)


func _on_button_pressed():
	AudioController.get_player('CalmMenuLoop').stop()
	Game.trigger_new_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _button_hovered(control: String):
	if _hovered != control:
		_hovered = control
		AudioController.get_player("MenuHoverSound").play()


func _button_unhovered():
	_hovered = null
