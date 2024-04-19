class_name FriendlySpawner
extends Area2D

@onready var friendly = preload("res://scenes/fighting/friendly.tscn")
@onready var alternate_texture = preload("res://assets/fighters/hero_2.png")
var spawn_rate = 12
var counter = 11

func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)

func on_global_ticker_timeout():
	counter += 1
	if counter == spawn_rate:
		var friendly_instance = friendly.instantiate()
		get_parent().add_child(friendly_instance)
		if randi() % 2:
			friendly_instance.get_node("Sprite2D").texture = alternate_texture
		friendly_instance.global_position = self.global_position
		counter = 0

func _process(_delta):
	pass

func _on_area_entered(area):
	if area is Enemy:
		GlobalStats.update_health(-10)
		area.queue_free()
		
