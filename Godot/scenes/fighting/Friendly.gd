extends Area2D

@onready var ray = $RayCast2D

var tile_size = 64

# Called when the node enters the scene tree for the first time.
func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout) 
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

func on_global_ticker_timeout():
	move()

func move():
	ray.target_position = Vector2.RIGHT * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		position += Vector2.RIGHT * tile_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
