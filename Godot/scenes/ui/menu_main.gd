extends Control


var _heros: Array = [
	preload('res://assets/fighters/hero_1.png'),
	preload('res://assets/fighters/hero_2.png'),
	preload('res://assets/fighters/hero_3.png'),
]


var _enemies: Array = [
	preload('res://assets/fighters/enemy.png'),
	preload('res://assets/fighters/enemy_2.png'),
	preload('res://assets/fighters/enemy_3.png'),
	# preload('res://assets/fighters/enemy_4.png'), # Is too wide for main menu in current setup!
]


var _hovered = null


func _ready():
	if OS.get_name() == "Web":
		%Quit.queue_free()
	%CharacterLeft.texture = _heros.pick_random()
	%CharacterRight.texture = _enemies.pick_random()


func _on_play_pressed():
	GameParameters.is_tutorial = false
	AudioController.get_player("MenuPressSound").play()
	# AudioController.get_player("GameStartSound").play()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_tutorial_pressed():
	GameParameters.is_tutorial = true
	AudioController.get_player("MenuPressSound").play()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed():
	get_tree().quit()
	AudioController.get_player("MenuPressSound").play()


func _on_settings_pressed():
	$MenuSettings.show()
	AudioController.get_player("MenuPressSound").play()


func _on_credits_pressed():
	$MenuCredits.show()
	%CreditsBackButton.grab_focus()
	AudioController.get_player("MenuPressSound").play()


func _on_credits_back_button_pressed():
	$MenuCredits.hide()
	AudioController.get_player("MenuPressSound").play()


func _button_hovered(button: String):
	if _hovered != button:
		_hovered = button
		AudioController.get_player("MenuHoverSound").play()


func _button_unhovered():
	_hovered = null
