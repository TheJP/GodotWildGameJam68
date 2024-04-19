extends Node2D


@onready var _item_scene = preload('res://scenes/crafting/item.tscn')
var _gear_tween: Tween
var _state_number := 0


func _ready():
	global_position = Tile.snap_crafting(global_position, Vector2i(2, 1))

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
		AudioController.get_player("ItemCombinationSound").play(0)
		await Ticker.timer.timeout
		if _state_number != local_state:
			return # Slots changed since wait, return to prevent issues like double crafting.
		if not is_instance_valid($LeftSlot.item) or not is_instance_valid($RightSlot.item):
			return
		$LeftSlot.is_crafting = true
		$RightSlot.is_crafting = true
		await Ticker.timer.timeout
		_craft()
		$LeftSlot.is_crafting = false
		$RightSlot.is_crafting = false
		_gear_tween.pause()
	else:
		_gear_tween.pause()
		AudioController.get_player("ItemCombinationSound").stop()

func _craft():
	var new_left = null
	var new_right = null
	if $LeftSlot.item.type in Item.crafting and $RightSlot.item.type in Item.crafting[$LeftSlot.item.type]:
		var recipe = Item.crafting[$LeftSlot.item.type][$RightSlot.item.type]
		if recipe.is_id:
			new_left = $LeftSlot.item
			new_right = $RightSlot.item
		if not recipe.is_nothing:
			new_left = _spawn_item(recipe.type, $LeftSlot.global_position)
	else:
		new_left = _spawn_item(Item.Type.TRASH, $LeftSlot.global_position)
	$LeftSlot.crafted_item(new_left)
	$RightSlot.crafted_item(new_right)
	check_progress(new_left.type)

func check_progress(type):
	if(type == Item.Type.HAMMER):
		if(GlobalStats.progress < 1):
			GlobalStats.set_progress_level(1)
	elif(type == Item.Type.STEEL):
		if(GlobalStats.progress < 2):
			GlobalStats.set_progress_level(2)
	elif(type == Item.Type.SWORD):
		if(GlobalStats.progress < 3):
			GlobalStats.set_progress_level(3)

func _spawn_item(type: Item.Type, p_position: Vector2) -> Node2D:
	var item = _item_scene.instantiate()
	item.type = type
	item.global_position = p_position
	get_parent().add_child(item)
	return item


func _on_destroyed():
	_state_number += 1
	if $LeftSlot.item != null:
		$LeftSlot.item.queue_free()
	if $RightSlot.item != null:
		$RightSlot.item.queue_free()
	queue_free()
