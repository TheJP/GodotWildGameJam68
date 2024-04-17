extends Node2D


@onready var _ray: ShapeCast2D = $ShapeCast2D
var _destroyable := {
	Tile.Type.CRAFTER: true,
	Tile.Type.PIPE: true,
	Tile.Type.TRASH_CAN: true,
}


func _input(event):
	if event is InputEventMouseMotion:
		global_position = Tile.snap_crafting(event.position)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
			return

		get_viewport().set_input_as_handled()

		_ray.target_position = Vector2(0, 0)
		_ray.force_shapecast_update()
		var machine = _ray.get_collider(0)
		if machine == null:
			return

		if not (machine is Machine):
			push_error('node "{0}" is on the wrong intersection layer'.format([machine.name]))
			return
		if machine.type not in _destroyable:
			return

		machine.destroy()

