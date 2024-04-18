class_name EnemySpawner
extends Area2D

@onready var enemy = preload("res://scenes/fighting/enemy.tscn")
var spawn_rate = 12
var strong_enemy_interval = 5
var strong_enemy_interval_counter = 0
var counter = 0

func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)

func on_global_ticker_timeout():
	counter += 1
	if counter == spawn_rate:
		strong_enemy_interval_counter += 1
		var enemy_instance = enemy.instantiate()
		if strong_enemy_interval_counter % strong_enemy_interval == 0:
			enemy_instance.get_node("Sprite2D").modulate = Color.BLUE
			enemy_instance.health = 10
			enemy_instance.damage = 3
			strong_enemy_interval_counter = 0	
		get_parent().add_child(enemy_instance)
		enemy_instance.global_position = self.global_position
		counter = 0

func _process(_delta):
	pass
