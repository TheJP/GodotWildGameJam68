class_name Friendly
extends Area2D

@onready var move_ray = $MoveRay
@onready var range_ray = $RangeRay
@onready var right_hand_sprite = $RightHand
@onready var left_hand_sprite = $LeftHand
var right_hand_occupied = false
var left_hand_occupied = false
var right_hand_item_type = null
var left_hand_item_type = null

var directions = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]
var direction_index = 0
var animation_speed = 3
var tile_size = GameParameters.tilesize

var health = 3
var damage = 1
var move_frequency = 3
var counter = 1

func _ready():
	Ticker.timer.timeout.connect(on_global_ticker_timeout)
	global_position = Tile.snap_fighting(global_position)

func on_global_ticker_timeout():
	act()

func try_throw_item():
	range_ray.target_position = directions[direction_index] * tile_size * 3
	range_ray.force_raycast_update()
	if range_ray.is_colliding():
		var collider = range_ray.get_collider()
		if collider is Enemy:
			if right_hand_occupied && is_instance_valid(collider):
				if Item.stat_modifiers[right_hand_item_type].throwable > 0:
					var tween = create_tween()
					tween.tween_property(right_hand_sprite, "global_position",
						collider.global_position, 1.0/(animation_speed*2)).set_trans(Tween.TRANS_SINE)
					await tween.finished
					right_hand_sprite.texture = null
					right_hand_occupied = false
					right_hand_item_type = null
			if left_hand_occupied && is_instance_valid(collider):
				if Item.stat_modifiers[left_hand_item_type].throwable > 0:
					var tween = create_tween()
					tween.tween_property(left_hand_sprite, "global_position",
						collider.global_position, 1.0/(animation_speed*2)).set_trans(Tween.TRANS_SINE)
					collider.take_damage(Item.stat_modifiers[left_hand_item_type].throwable)
					await tween.finished
					collider.take_damage(Item.stat_modifiers[left_hand_item_type].throwable)
					left_hand_sprite.texture = null
					left_hand_occupied = false
					left_hand_item_type = null

func act():
	try_throw_item()
	counter += 1
	move_ray.target_position = directions[direction_index] * tile_size
	move_ray.force_raycast_update()
	if !move_ray.is_colliding():
		if(counter == move_frequency):
			counter = 0
			if !move_ray.is_colliding():
				var tween = create_tween()
				tween.tween_property(self, "position",
					position + directions[direction_index] * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
				await tween.finished
	else:
		if(counter == move_frequency):
			counter = 0
		var collider = move_ray.get_collider()
		if collider is Enemy:
			collider.take_damage(damage)
		elif collider is Wall:
			direction_index += 1
			

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
		take_damage(item_stat_modifiers.health)
	else:
		health += item_stat_modifiers.health
	damage = max(damage + item_stat_modifiers.damage, 0)
	return true

func take_damage(amount):
	health -= amount
	$Sprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE
	if health <= 0:
		self.queue_free()

func _process(_delta):
	pass
