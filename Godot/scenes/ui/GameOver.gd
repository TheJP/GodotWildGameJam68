extends CanvasLayer

func _ready():
	var score = GlobalStats.times_spawned
	var highscore = GlobalStats.highscore
	var is_new_highscore: bool = score > highscore
	%Score.text = str(score)
	%PreviousHighscore.text = str(highscore)
	%NewHighscore.visible = is_new_highscore
	%HighscoreLabel.visible = not is_new_highscore
	%PreviousHighscoreLabel.visible = is_new_highscore
	GlobalStats.highscore = max(highscore, score)


func _on_button_pressed():
	GlobalStats.new_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
