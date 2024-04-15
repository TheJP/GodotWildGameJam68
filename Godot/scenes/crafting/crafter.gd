extends Node2D


@onready var _item_scene = preload('res://scenes/crafting/item.tscn')
var _gear_tween: Tween
var _state_number := 0


func _ready():
	global_position = global_position.snapped(Vector2.ONE * GameParameters.craft_tilesize)
	global_position += Vector2.DOWN * (GameParameters.craft_tilesize * 0.5)

	_gear_tween = get_tree().create_tween()
	_gear_tween.tween_property($Gear, "rotation", PI * 0.67, 1)
	_gear_tween.tween_property($Gear, "rotation", PI * 1.33, 1)
	_gear_tween.tween_property($Gear, "rotation", PI * 2, 1)
	_gear_tween.tween_property($Gear, "rotation", 0, 0)
	_gear_tween.set_loops().pause()


func _on_hovered():
	scale = Vector2(1.1, 1.1)


func _on_unhovered():
	scale = Vector2(1, 1)


func _on_received_item():
	_slots_changed()


func _on_lost_item():
	_slots_changed()


func _slots_changed():
	_state_number += 1
	var local_state = _state_number
	if $LeftSlot.item != null and $RightSlot.item != null:
		_gear_tween.play()

		# Craft item(s).
		await Ticker.timer.timeout
		await Ticker.timer.timeout
		if _state_number != local_state:
			return # Slots changed since wait, return to prevent issues like double crafting.
		$LeftSlot.is_crafting = true
		$RightSlot.is_crafting = true
		await Ticker.timer.timeout
		_craft()
		$LeftSlot.is_crafting = false
		$RightSlot.is_crafting = false
		_gear_tween.pause()
	else:
		_gear_tween.pause()


func _craft():
	var new_left = null
	var new_right = null
	if $LeftSlot.item.type in Item.crafting and $RightSlot.item.type in Item.crafting[$LeftSlot.item.type]:
		var recipe = Item.crafting[$LeftSlot.item.type][$RightSlot.item.type]
		if recipe.is_id:
			return
		if not recipe.is_nothing:
			new_left = _spawn_item(recipe.type, $LeftSlot.global_position)
	else:
		new_left = _spawn_item(Item.Type.TRASH, $LeftSlot.global_position)
	$LeftSlot.crafted_item(new_left)
	$RightSlot.crafted_item(new_right)


func _spawn_item(type: Item.Type, p_position: Vector2) -> Node2D:
	var item = _item_scene.instantiate()
	item.type = type
	item.global_position = p_position
	get_tree().root.add_child(item)
	return item
