class_name Enemy
extends Area2D

@onready var move_ray = $MoveRay
@onready var melee_ray = $MeleeRay
@onready var health_bar = $HealthBar
@onready var fire_animation = $FlameDamage

var animation_speed = 3
var tile_size = GameParameters.tilesize

var directions = [Vector2.LEFT, Vector2.UP, Vector2.DOWN, Vector2(-1, 1), Vector2(-1, -1)]

var _hovering = false

var health = 20
var damage = 1
var move_frequency = 2
var counter = 0

var is_plant = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)
	health_bar.max_value = health
	health_bar.visible = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if event.pressed && _hovering:
			if ClickCooldown.try_click_action():
				take_damage(1)

func _on_mouse_entered():
	_hovering = true

func _on_mouse_exited():
	_hovering = false

func on_global_ticker_timeout():
	act()

func act():
	counter += 1
	move_ray.target_position = Vector2.LEFT * tile_size
	move_ray.force_raycast_update()
	var did_attack = false
	for direction in directions:
		melee_ray.target_position = direction * tile_size
		melee_ray.force_raycast_update()
		if melee_ray.is_colliding():
			var collider = melee_ray.get_collider()
			if collider is Friendly:
				var tween = create_tween()
				var starting_position = self.position
				tween.tween_property(self, "position",
					position + direction * tile_size / 4.0, 1.0/(4*animation_speed)).set_trans(Tween.TRANS_SINE)
				await tween.finished
				tween = create_tween()
				tween.tween_property(self, "position",
					starting_position, 1.0/(4*animation_speed)).set_trans(Tween.TRANS_SINE)
				await tween.finished
				if is_instance_valid(collider):
					collider.take_damage(damage)
				did_attack = true
				break
	if !move_ray.is_colliding() && !did_attack:
		if(counter == move_frequency):
			if self.is_inside_tree():
				var tween = create_tween()
				tween.tween_property(self, "position",
					position + Vector2.LEFT * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
				await tween.finished


	if(counter == move_frequency):
			counter = 0

func increase_health(amount):
		health += amount
		health_bar.max_value = health
		health_bar.value = health

func take_damage(amount, is_fire: bool = false):
	if(is_fire && self.is_plant):
		amount += 100
	if health_bar.visible == false:
		health_bar.visible = true
	health -= amount	
	health_bar.value = health
	$Sprite2D.modulate = Color.RED
	if(is_fire && self.is_plant):
		fire_animation.visible = true
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE
	await get_tree().create_timer(0.5).timeout
	fire_animation.visible = false
	var sound_index = randi() % 3
	if health <= 0:
		if sound_index == 0:
			AudioController.get_player("EnemyDeathSound1").play()
		elif sound_index == 1:
			AudioController.get_player("EnemyDeathSound2").play()
		else:
			AudioController.get_player("EnemyDeathSound3").play()
		self.queue_free()
	else:
		if sound_index == 0:
			AudioController.get_player("DamageTickSound1").play()
		elif sound_index == 1:
			AudioController.get_player("DamageTickSound2").play()
		else:
			AudioController.get_player("DamageTickSound3").play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
