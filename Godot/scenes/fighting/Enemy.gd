class_name Enemy
extends Area2D

@onready var ray = $RayCast2D

var animation_speed = 3
var tile_size = GameParameters.tilesize

var health = 3
var damage = 1
var move_frequency = 3
var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)

func on_global_ticker_timeout():
	move()

func move():
	counter += 1
	ray.target_position = Vector2.LEFT * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		if(counter == move_frequency):
			counter = 0
			var tween = create_tween()
			tween.tween_property(self, "position",
				position + Vector2.LEFT * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
			await tween.finished
	else:
		if(counter == move_frequency):
			counter = 0
		var collider = ray.get_collider()
		if collider is Friendly:
			collider.take_damage(damage)

func take_damage(amount):
	health -= amount
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE
	if health <= 0:
		self.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
