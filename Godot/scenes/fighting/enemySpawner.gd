class_name EnemySpawner
extends Area2D

@onready var enemy = preload("res://scenes/fighting/enemy.tscn")
@onready var texture_1 = preload("res://assets/fighters/enemy.png")
@onready var texture_2 = preload("res://assets/fighters/enemy_2.png")
@onready var texture_3 = preload("res://assets/fighters/enemy_3.png")
var spawn_rate = 36
var counter = 35
var increase_health_frequency = 2
var increase_damage_frequency = 5
var health_bonus = 0
var damage_bonus = 0

func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)

func on_global_ticker_timeout():
	counter += 1
	if counter == spawn_rate:
		var enemy_instance = enemy.instantiate()
		get_parent().add_child(enemy_instance)
		enemy_instance.increase_health(health_bonus)
		enemy_instance.damage += max(0, damage_bonus - (randi() % 3))
		if(enemy_instance.damage > 2):
			enemy_instance.get_node("Sprite2D").texture = texture_1
		elif(enemy_instance.damage > 1):
			enemy_instance.get_node("Sprite2D").texture = texture_2
		else:
			enemy_instance.get_node("Sprite2D").texture = texture_3
		enemy_instance.global_position = self.global_position
		if GlobalStats.times_spawned % increase_health_frequency == 0:
			health_bonus += 1
		if GlobalStats.times_spawned % increase_damage_frequency == 0:
			damage_bonus += 1
		GlobalStats.times_spawned += 1
		counter = 0

func _process(_delta):
	pass
