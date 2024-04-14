extends Node2D


var _gear_tween: Tween


func _ready():
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
	if $LeftSlot.item != null and $RightSlot.item != null:
		_gear_tween.play()
	else:
		_gear_tween.pause()
