extends Area2D


@onready var ray: RayCast2D = $RayCast2D
@onready var enemy_scene = preload("res://scenes/fighting/enemy.tscn")


@export var spawn_rate = 36
@onready var _counter = spawn_rate - 1


func _ready():
	global_position = Tile.snap_crafting(global_position)
	Game.timer.timeout.connect(on_global_ticker_timeout)


func on_global_ticker_timeout():
	_counter += 1
	if _counter >= spawn_rate:
		_spawn_enemy()
		GlobalStats.times_spawned += 1
		_counter = 0


func _spawn_enemy():
	for _i in range(4):
		ray.rotate(PI * 0.5)
		ray.force_raycast_update()
		var collider = ray.get_collider()
		if collider is Road:
			if collider.fighter != null:
				continue
			var enemy = enemy_scene.instantiate()
			enemy.global_position = collider.global_position
			get_parent().add_child(enemy)
			collider.fighter = enemy
			return
