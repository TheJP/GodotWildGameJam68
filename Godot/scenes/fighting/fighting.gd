extends Node2D

var spawn_rate = 3
var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout) 

func on_global_ticker_timeout():
	counter += 1
	if counter == spawn_rate:
		var friendly = load("res://scenes/fighting/friendly.tscn")
		var friendly_instance = friendly.instantiate()
		add_child(friendly_instance)
		var enemy = load("res://scenes/fighting/enemy.tscn")
		var enemy_instance = enemy.instantiate()
		add_child(enemy_instance)
		counter = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
