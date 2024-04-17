class_name RemoveTool
extends Node2D


static var _destroyable := {
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

	RemoveTool.try_remove(_ray.get_collider(0))


static func try_remove(machine: Node2D):
	if not (machine is Machine):
		push_error('node "{0}" is on the wrong intersection layer'.format([machine.name]))
		return
	if machine.type not in _destroyable:
		return

	# Reset pipe connections after machine was removed.
	var parts := [machine.get_parent().get_node("LeftSlot"), machine.get_parent().get_node("RightSlot")] if machine is CrafterSlot else [machine]
	for part in parts:
		var ray := RayCast2D.new()
		ray.collision_mask = 2
		ray.collide_with_areas = true
		part.add_child(ray)
		var direction := Pipe.Direction.DOWN
		for _i in range(4):
			ray.target_position = Pipe.direction_to_vector[direction] * GameParameters.craft_tilesize
			ray.force_raycast_update()
			var collider = ray.get_collider()
			if collider is Pipe:
				collider.connections &= ~Pipe.direction_opposite[direction]
			direction = Pipe.rotate_direction_skip_none(direction)

	machine.destroy()
