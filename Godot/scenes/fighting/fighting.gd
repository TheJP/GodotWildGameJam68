extends Node2D

@onready var friendly = preload("res://scenes/fighting/friendly.tscn")
@onready var enemy = preload("res://scenes/fighting/enemy.tscn")
var spawn_rate = 3
var counter = 0

func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)

func on_global_ticker_timeout():
	counter += 1
	if counter == spawn_rate:
		var friendly_instance = friendly.instantiate()
		add_child(friendly_instance)
		var enemy_instance = enemy.instantiate()
		add_child(enemy_instance)
		counter = 0

func _process(delta):
	pass
