extends CanvasLayer

@onready var score = %Score

func _ready():
	score.text = "Waves Survived : {0}".format([GlobalStats.times_spawned])

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
