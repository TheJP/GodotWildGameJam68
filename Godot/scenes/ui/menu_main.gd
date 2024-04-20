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


func _ready():
	if OS.get_name() == "Web":
		%Quit.queue_free()
	%CharacterLeft.texture = _heros.pick_random()
	%CharacterRight.texture = _enemies.pick_random()


func _on_play_pressed():
	GameParameters.is_tutorial = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_tutorial_pressed():
	GameParameters.is_tutorial = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	$MenuSettings.show()


func _on_credits_pressed():
	$MenuCredits.show()
