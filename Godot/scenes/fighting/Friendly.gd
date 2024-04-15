class_name Friendly
extends Area2D

@onready var ray = $RayCast2D
@onready var itemSprite = $Item
var has_item = false

var animation_speed = 3
var tile_size = GameParameters.tilesize

var health = 3
var damage = 1
var move_frequency = 3
var counter = 1

func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = global_position.snapped(Vector2.ONE * tile_size)
	global_position += Vector2.ONE * tile_size/2

func on_global_ticker_timeout():
	move()

func move():
	counter += 1
	ray.target_position = Vector2.RIGHT * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		if(counter == move_frequency):
			counter = 0
			if !ray.is_colliding():
				var tween = create_tween()
				tween.tween_property(self, "position",
					position + Vector2.RIGHT * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
				await tween.finished
	else:
		if(counter == move_frequency):
			counter = 0
		var collider = ray.get_collider()
		if collider is Enemy:
			collider.take_damage(damage)

func set_item(p_item: Node2D):
	has_item = true
	itemSprite.texture = p_item.get_node("Sprite2D").texture

func take_damage(amount):
	health -= amount
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE
	if health <= 0:
		self.queue_free()

func _process(_delta):
	pass
