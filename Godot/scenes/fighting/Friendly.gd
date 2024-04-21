class_name Friendly
extends DropTarget


class Hand:
	var sprite: Sprite2D
	var level_one: CPUParticles2D
	var level_two: CPUParticles2D
	var level_three: CPUParticles2D
	var item_type = null
	var occupied := false


var left_hand: Hand = Hand.new()
var right_hand: Hand = Hand.new()

@onready var move_ray = $MoveRay
@onready var range_ray = $RangeRay
@onready var melee_ray = $MeleeRay
@onready var health_bar = $HealthBar
@onready var _animation_player = $AnimationPlayer
var has_fire_weapon = false

var directions = [Vector2.RIGHT, Vector2.DOWN, Vector2.UP, Vector2(1, 1), Vector2(1, -1)]
var animation_speed = 3
var tile_size = GameParameters.tilesize

var max_health = 4
var health = max_health
var damage = 1
var move_frequency = 2
var counter = -3


func _ready():
	left_hand.sprite = $LeftHand
	left_hand.level_one = $LeftHand/mode_one
	left_hand.level_two = $LeftHand/mode_two
	left_hand.level_three = $LeftHand/mode_three

	right_hand.sprite = $RightHand
	right_hand.level_one = $RightHand/mode_one
	right_hand.level_two = $RightHand/mode_two
	right_hand.level_three = $RightHand/mode_three

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
			if right_hand.occupied && is_instance_valid(collider):
				did_throw = await _throw_with_hand(collider, right_hand)
			if left_hand.occupied && is_instance_valid(collider):
				did_throw = await _throw_with_hand(collider, left_hand) or did_throw
	return did_throw


func _throw_with_hand(enemy: Enemy, hand: Hand) -> bool:
	var stats: Item.StatModifier = Item.stat_modifiers[hand.item_type]
	if stats.throwable <= 0:
		return false

	var start_position = hand.sprite.global_position
	var tween = create_tween()
	tween.tween_property(hand.sprite, "global_position", enemy.global_position, 1.0/(animation_speed*2)).set_trans(Tween.TRANS_SINE)
	var rotation_tween = create_tween().set_loops()
	rotation_tween.tween_property(hand.sprite, "rotation", PI * 0.67, 0.05)
	rotation_tween.tween_property(hand.sprite, "rotation", PI * 1.33, 0.05)
	rotation_tween.tween_property(hand.sprite, "rotation", PI * 2, 0.05)
	rotation_tween.tween_property(hand.sprite, "rotation", 0, 0)
	if is_instance_valid(enemy):
		enemy.take_damage(stats.throwable)
	await tween.finished
	if !stats.ranged:
		hand.sprite.texture = null
		hand.occupied = false
		hand.item_type = null
	else:
		tween = create_tween()
		tween.tween_property(hand.sprite, "global_position", start_position, 1.0/(animation_speed*2)).set_trans(Tween.TRANS_SINE)
		await tween.finished
	rotation_tween.kill()
	hand.sprite.rotation = 0
	return true


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
						if(self.has_fire_weapon):
							collider.take_damage(damage, true)
						else:
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
	if !right_hand.occupied:
		_pickup_item(right_hand, p_item)
	elif !left_hand.occupied:
		_pickup_item(left_hand, p_item)
	else:
		return false

	if (item_stat_modifiers.health < 0):
		take_damage(-item_stat_modifiers.health)
	else:
		increase_health(item_stat_modifiers.health)
	if item_stat_modifiers.is_fire:
		has_fire_weapon = true
	damage = max(damage + item_stat_modifiers.damage, 0)
	return true


func _pickup_item(hand: Hand, p_item: Node2D):
	var item_stat_modifiers = Item.stat_modifiers[p_item.type]
	if item_stat_modifiers.destroy_on_pickup:
		return

	hand.sprite.texture = p_item.get_node("Sprite2D").texture
	hand.occupied = true
	hand.item_type = p_item.type
	if(item_stat_modifiers.level == 1):
		hand.level_one.visible = true
	elif(item_stat_modifiers.level == 2):
		hand.level_two.visible = true
	elif(item_stat_modifiers.level == 3):
		hand.level_three.visible = true


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
