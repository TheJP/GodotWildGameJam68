class_name FriendlySpawner
extends Area2D

@onready var friendly = preload("res://scenes/fighting/friendly.tscn")
var spawn_rate = 8
var counter = 0

func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)

func on_global_ticker_timeout():
	counter += 1
	if counter == spawn_rate:
		var friendly_instance = friendly.instantiate()
		get_parent().add_child(friendly_instance)
		friendly_instance.global_position = self.global_position + Vector2.RIGHT * GameParameters.tilesize
		counter = 0

func _process(_delta):
	pass
