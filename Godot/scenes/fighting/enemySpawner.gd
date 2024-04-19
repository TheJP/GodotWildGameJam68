class_name EnemySpawner
extends Area2D

@onready var enemy = preload("res://scenes/fighting/enemy.tscn")
var spawn_rate = 36
var counter = 35
var times_spawned = 0
var increase_health_frequency = 1
var health_bonus = 0

func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)

func on_global_ticker_timeout():
	counter += 1
	if counter == spawn_rate:
		var enemy_instance = enemy.instantiate()
		get_parent().add_child(enemy_instance)
		enemy_instance.health += health_bonus
		enemy_instance.global_position = self.global_position
		times_spawned += 1
		if times_spawned % increase_health_frequency == 0:
			health_bonus += 2
		counter = 0

func _process(_delta):
	pass
