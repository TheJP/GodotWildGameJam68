extends Control


func _ready():
	if OS.get_name() == "Web":
		%Quit.queue_free()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	$MenuSettings.show()


func _on_credits_pressed():
	$MenuCredits.show()