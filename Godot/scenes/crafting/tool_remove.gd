class_name RemoveTool
extends Node2D


static var destroyable := {
	Tile.Type.CRAFTER: true,
	Tile.Type.PIPE: true,
	Tile.Type.TRASH_CAN: true,
}


var _dragging := false
@onready var _ray: ShapeCast2D = $ShapeCast2D


func _input(event):
	if event is InputEventMouseMotion:
		global_position = Tile.snap_crafting(event.position)
		if _dragging:
			_try_remove()
	elif event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = false


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			_try_remove()
			_dragging = true


func _try_remove():
	_ray.target_position = Vector2(0, 0)
	_ray.force_shapecast_update()
	if not _ray.is_colliding():
		return
	var machine = _ray.get_collider(0)

	if not (machine is Machine):
		push_error('node "{0}" is on the wrong intersection layer'.format([machine.name]))
		return
	if machine.type not in destroyable:
		return

	machine.destroy()
