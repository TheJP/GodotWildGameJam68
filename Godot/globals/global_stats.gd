extends Node

var factory_health = 100
signal update_health_bar

func update_health(amount):
	factory_health += amount
	update_health_bar.emit()
	if factory_health <= 0:
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
