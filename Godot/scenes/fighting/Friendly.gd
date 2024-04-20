class_name Friendly
extends DropTarget

@onready var move_ray = $MoveRay
@onready var range_ray = $RangeRay
@onready var melee_ray = $MeleeRay
@onready var right_hand_sprite = $RightHand
@onready var left_hand_sprite = $LeftHand
@onready var health_bar = $HealthBar
@onready var _animation_player = $AnimationPlayer
var right_hand_occupied = false
var left_hand_occupied = false
var right_hand_item_type = null
var left_hand_item_type = null

var directions = [Vector2.RIGHT, Vector2.DOWN, Vector2.UP, Vector2(1, 1), Vector2(1, -1)]
var animation_speed = 3
var tile_size = GameParameters.tilesize

var max_health = 4
var health = max_health
var damage = 1
var move_frequency = 2
var counter = -3


func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)
	health_bar.max_value = health
	health_bar.visible = false

func hover():
	scale = Vector2(1.1, 1.1)

func unhover():
	scale = Vector2(1, 1)

func try_drop(_item: Node2D) -> bool:
	if try_set_item(_item):
		_item.queue_free()
		return true
	else:
		return false

func try_remove() -> bool:
	return false

func on_global_ticker_timeout():
	act()

func try_throw_item() -> bool:
	var did_throw = false
	range_ray.target_position = Vector2.RIGHT * tile_size * 3
	range_ray.force_raycast_update()
	if range_ray.is_colliding():
		var collider = range_ray.get_collider()
		if collider is Enemy && self.global_position.distance_to(collider.global_position) > tile_size:
			if right_hand_occupied && is_instance_valid(collider):
				if Item.stat_modifiers[right_hand_item_type].throwable > 0:
					var tween = create_tween()
					var start_position = right_hand_sprite.global_position
					tween.tween_property(right_hand_sprite, "global_position",
						collider.global_position, 1.0/(animation_speed*2)).set_trans(Tween.TRANS_SINE)
					if(is_instance_valid(collider)):
						collider.take_damage(Item.stat_modifiers[right_hand_item_type].throwable)
					await tween.finished
					if !Item.stat_modifiers[right_hand_item_type].ranged:
						right_hand_sprite.texture = null
						right_hand_occupied = false
						right_hand_item_type = null
					else:
						tween = create_tween()
						tween.tween_property(right_hand_sprite, "global_position",
						start_position, 1.0/(animation_speed*2)).set_trans(Tween.TRANS_SINE)
					await tween.finished
					did_throw = true
			if left_hand_occupied && is_instance_valid(collider):
				if Item.stat_modifiers[left_hand_item_type].throwable > 0:
					var tween = create_tween()
					var start_position = left_hand_sprite.global_position
					tween.tween_property(left_hand_sprite, "global_position",
						collider.global_position, 1.0/(animation_speed*2)).set_trans(Tween.TRANS_SINE)
					if(is_instance_valid(collider)):
						collider.take_damage(Item.stat_modifiers[left_hand_item_type].throwable)
					await tween.finished
					if !Item.stat_modifiers[left_hand_item_type].ranged:
						left_hand_sprite.texture = null
						left_hand_occupied = false
						left_hand_item_type = null
					else:
						tween = create_tween()
						tween.tween_property(left_hand_sprite, "global_position",
							start_position, 1.0/(animation_speed*2)).set_trans(Tween.TRANS_SINE)
					await tween.finished
					did_throw = true
	return did_throw

func act():
	var did_throw = await try_throw_item()
	counter += 1
	move_ray.target_position = Vector2.RIGHT * tile_size
	move_ray.force_raycast_update()
	var did_attack = false
	if !did_throw:
		for direction in directions:
			melee_ray.target_position = direction * tile_size
			melee_ray.force_raycast_update()
			if melee_ray.is_colliding():
				var collider = melee_ray.get_collider()
				if collider is Enemy:
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
	if !move_ray.is_colliding() && !did_throw && !did_attack:
		if(counter == move_frequency):
			range_ray.target_position = Vector2.RIGHT * tile_size * 5
			range_ray.force_raycast_update()
			if !move_ray.is_colliding():
				var tween = create_tween()
				tween.tween_property(self, "position",
					position + Vector2.RIGHT * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
				await tween.finished

	if(counter == move_frequency):
			counter = 0

func try_set_item(p_item: Node2D) -> bool:
	var item_stat_modifiers = Item.stat_modifiers[p_item.type]
	if !right_hand_occupied:
		if !item_stat_modifiers.destroy_on_pickup:
			right_hand_sprite.texture = p_item.get_node("Sprite2D").texture
			right_hand_occupied = true
			right_hand_item_type = p_item.type
	elif !left_hand_occupied:
		if !item_stat_modifiers.destroy_on_pickup:
			left_hand_sprite.texture = p_item.get_node("Sprite2D").texture
			left_hand_occupied = true
			left_hand_item_type = p_item.type
	else:
		return false

	if (item_stat_modifiers.health < 0):
		take_damage(-item_stat_modifiers.health)
	else:
		increase_health(item_stat_modifiers.health)
	damage = max(damage + item_stat_modifiers.damage, 0)
	return true

func increase_health(amount):
		health += amount
		max_health += amount
		health_bar.value = health
		health_bar.max_value = max_health

func take_damage(amount):
	if health_bar.visible == false:
		health_bar.visible = true
	health -= amount
	_animation_player.play("taking_damage")
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE
	health_bar.value = health
	if health <= 0:
		var sound_index = randi() % 3
		if sound_index == 0:
			AudioController.get_player("HeroDeathSound2").play()
		elif sound_index == 1:
			AudioController.get_player("HeroDeathSound3").play()
		else:
			AudioController.get_player("HeroDeathSound4").play()
		self.queue_free()

func _process(_delta):
	pass
