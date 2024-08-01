extends Node2D


@onready var _item_scene = preload('res://scenes/crafting/item.tscn')
var _gear_tween: Tween
var _state_number := 0
var _disable_crafting := false


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


func _on_left_slot_changed():
	_disable_crafting = false
	_slots_changed()

func _on_right_slot_changed():
	_slots_changed()


func _slots_changed():
	_state_number += 1
	var local_state = _state_number
	if $LeftSlot.item != null and $RightSlot.item != null:
		if _disable_crafting:
			return
		# Craft item(s).
		await Game.timer.timeout
		if _state_number != local_state:
			return
		_animate_craft_items()
		_gear_tween.play()
		# Disabled for now, because it was constant noise.
		# if !AudioController.get_player("ItemCraftLoop").playing:
			# AudioController.get_player("ItemCraftLoop").play()
		await Game.timer.timeout
		if _state_number != local_state:
			return # Slots changed since wait, return to prevent issues like double crafting.
		if not is_instance_valid($LeftSlot.item) or not is_instance_valid($RightSlot.item):
			return
		_animate_craft_items()
		$LeftSlot.is_crafting = true
		$RightSlot.is_crafting = true
		await Game.timer.timeout
		_craft()
		_animate_crafted()
		_disable_crafting = true
		$LeftSlot.is_crafting = false
		$RightSlot.is_crafting = false
		_gear_tween.pause()
		# AudioController.get_player("ItemCraftLoop").stop()
	else:
		_gear_tween.pause()
		# AudioController.get_player("ItemCraftLoop").stop()


func _animate_craft_items():
	_animate_craft_item($LeftSlot)
	_animate_craft_item($RightSlot)


func _animate_craft_item(slot: CrafterSlot):
	if slot.item == null or not is_instance_valid(slot.item):
		return
	var tween: Tween = slot.item.create_tween().set_parallel()
	var target: Vector2 = slot.item.global_position + (global_position - slot.global_position) * 0.5
	target = target.clamp(slot.global_position, global_position) if slot == $LeftSlot else target.clamp(global_position, slot.global_position)
	tween.tween_property(slot.item, 'global_position', target, 0.33).set_trans(Tween.TRANS_SINE)
	tween.tween_property(slot.item, 'scale', (slot.item.scale * 0.7).clamp(Vector2(0.5, 0.5), Vector2.ONE), 0.33).set_trans(Tween.TRANS_SINE)


func _animate_crafted():
	if $LeftSlot.item == null or not is_instance_valid($LeftSlot.item):
		return
	$LeftSlot.item.global_position = global_position
	$LeftSlot.item.scale = Vector2(0.5, 0.5)
	var tween: Tween = $LeftSlot.item.create_tween().set_parallel()
	tween.tween_property($LeftSlot.item, 'global_position', $LeftSlot.global_position, 0.33).set_trans(Tween.TRANS_SINE)
	tween.tween_property($LeftSlot.item, 'scale', Vector2.ONE, 0.33).set_trans(Tween.TRANS_SINE)


func _craft():
	var new_left = null
	var new_right = null
	if $LeftSlot.item.type in Item.crafting and $RightSlot.item.type in Item.crafting[$LeftSlot.item.type]:
		var recipe = Item.crafting[$LeftSlot.item.type][$RightSlot.item.type]
		if recipe.is_id:
			new_left = $LeftSlot.item
			new_right = $RightSlot.item
		if not recipe.is_nothing:
			new_left = _spawn_item(recipe.type)
			ItemDiscovery.set_recipe_discovered.call_deferred($LeftSlot.item.type, $RightSlot.item.type, recipe.type)
	else:
		new_left = _spawn_item(Item.Type.TRASH)
		ItemDiscovery.set_recipe_discovered.call_deferred($LeftSlot.item.type, $RightSlot.item.type, Item.Type.TRASH)
	$LeftSlot.crafted_item(new_left)
	$RightSlot.crafted_item(new_right)
	# AudioController.get_player("ItemCraftLoop").stop()
	AudioController.get_player("ItemDoneSound").play()
	if new_left != null:
		check_progress(new_left.type)


func check_progress(type):
	if type == Item.Type.HAMMER:
		if GlobalStats.progress < 1:
			GlobalStats.set_progress_level(1)
	elif type == Item.Type.HOT_STEEL or type == Item.Type.IRON_SHIELD:
		if GlobalStats.progress < 2:
			GlobalStats.set_progress_level(2)
	elif type == Item.Type.SWORD or type == Item.Type.BATTLE_HAMMER or type == Item.Type.BOOMERANG:
		if GlobalStats.progress < 3:
			GlobalStats.set_progress_level(3)
	elif type == Item.Type.SUPER_SWORD or type == Item.Type.SUPER_BATTLE_HAMMER or type == Item.Type.SUPER_BOOMERANG or type == Item.Type.SUPER_SHIELD:
		if GlobalStats.progress < 4:
			GlobalStats.set_progress_level(4)


func _spawn_item(type: Item.Type) -> Node2D:
	var item = _item_scene.instantiate()
	item.type = type
	get_parent().add_child(item)
	return item


func _on_destroyed():
	_state_number += 1
	if $LeftSlot.item != null:
		$LeftSlot.item.queue_free()
	if $RightSlot.item != null:
		$RightSlot.item.queue_free()
	AudioController.get_player("FactoryPartRemoveSound").play()
	# AudioController.get_player("ItemCraftLoop").stop()
	queue_free()
