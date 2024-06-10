class_name BuildTool
extends Node2D


@export var type: Tile.Type
@export var modulate_valid: Color = "9cff99"
@export var modulate_invalid: Color = "ff8585"
@export var is_intersection := false
var build_target: Node2D


@onready var _ray: ShapeCast2D = $ShapeCast2D
@onready var _sprite: Sprite2D = $Sprite2D
var _dragging := false
var _previous_build = null
var _mode := MOUSE_BUTTON_NONE


func _ready():
	ItemDiscovery.discovery.connect(func(_data): _dragging = false)
	if type == Tile.Type.PIPE and is_intersection:
		$Sprite2D.texture = Tile.sprite_intersection
	else:
		$Sprite2D.texture = Tile.sprites[type]
		is_intersection = false
	_mouse_move(get_viewport().get_mouse_position())


func _input(event):
	if event is InputEventMouseMotion:
		_mouse_move(event.position)
	elif event is InputEventMouseButton:
		if not event.pressed or _mode == event.button_index:
			_dragging = false


func _mouse_move(p_position: Vector2):
	var size = Vector2i(1, 1) if type != Tile.Type.CRAFTER else Vector2i(2, 1)
	global_position = Tile.snap_crafting(p_position, size)
	var valid := true
	if not _is_inside_bounds(global_position):
		valid = false
	elif not _is_colliding():
		valid = true
	elif type != Tile.Type.PIPE and type != Tile.Type.CRAFTER:
		valid = false
	else:
		for i in _ray.get_collision_count():
			if not (_ray.get_collider(i) is Pipe):
				valid = false
				break
	_sprite.modulate = modulate_valid if valid else modulate_invalid
	if _dragging:
		if _mode == MOUSE_BUTTON_LEFT:
			_try_build(p_position)
		elif _mode == MOUSE_BUTTON_RIGHT:
			_try_remove()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			return
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			get_viewport().set_input_as_handled()
			_previous_build = null
			_dragging = true
			_mode = event.button_index
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_build(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_try_remove()


func _try_remove():
	if not _is_colliding():
		return
	RemoveTool.try_remove(_ray.get_collider(0))


func _try_build(p_position):
	if type not in Tile.scenes:
		push_error('tried to build {0} but there is no scene for that'.format([type]))
		return

	var new_connections = 0
	if not is_instance_valid(_previous_build):
		_previous_build = null
	if type == Tile.Type.PIPE and _previous_build is Machine:
		var previous_connections = 0
		var current = Tile.snap_crafting(p_position)
		var other = _previous_build.global_position
		var x_same = abs(current.x - other.x) < 1.0
		var y_same = abs(current.y - other.y) < 1.0
		if x_same and y_same:
			pass
		elif x_same and abs(current.y - other.y) < GameParameters.tilesize * 1.5:
			if current.y - other.y < 0.0:
				previous_connections = Pipe.Direction.UP
				new_connections = Pipe.Direction.DOWN
			else:
				previous_connections = Pipe.Direction.DOWN
				new_connections = Pipe.Direction.UP
		elif y_same and abs(current.x - other.x) < GameParameters.tilesize * 1.5:
			if current.x - other.x < 0.0:
				previous_connections = Pipe.Direction.LEFT
				new_connections = Pipe.Direction.RIGHT
			else:
				previous_connections = Pipe.Direction.RIGHT
				new_connections = Pipe.Direction.LEFT
		if _previous_build is Pipe:
			if _previous_build.connections != _previous_build.connections | previous_connections:
				AudioController.get_player("PipePlacementSound").play()
			_previous_build.connections |= previous_connections

	if not _is_inside_bounds(p_position):
		return
	var is_colliding = _is_colliding()
	if is_colliding:
		_previous_build = _ray.get_collider(0)
		var collider = _ray.get_collider(0)
		if collider is Pipe:
			if not is_intersection:
				if collider.connections != collider.connections | new_connections:
					AudioController.get_player("PipePlacementSound").play()
				collider.connections |= new_connections
			else:
				if not collider.is_intersection:
					AudioController.get_player("PipePlacementSound").play()
				collider.is_intersection = true
				collider.connections = Pipe.CONNECTIONS_ALL
				collider.direction = Pipe.Direction.NONE
				_add_all_connections(collider)

		if type != Tile.Type.CRAFTER:
			return

		# Make crafter replace pipes (while preserving connections).
		for i in _ray.get_collision_count():
			if not (_ray.get_collider(i) is Pipe):
				return
		for i in _ray.get_collision_count():
			_ray.get_collider(i).destroy()

	var tile = Tile.scenes[type].instantiate()
	tile.global_position = p_position
	if type == Tile.Type.PIPE:
		tile.connections = new_connections if not is_intersection else Pipe.CONNECTIONS_ALL
		tile.is_intersection = is_intersection
	build_target.add_child(tile)

	match type:
		Tile.Type.TRASH_CAN:
			AudioController.get_player("TrashPlacementSound").play()
		Tile.Type.PIPE:
			AudioController.get_player("PipePlacementSound").play()
		Tile.Type.CRAFTER:
			AudioController.get_player("CombinerPlacementSound").play()
	if is_intersection:
		_add_all_connections(tile)

	_previous_build = tile


func _add_all_connections(pipe: Pipe):
	var ray := RayCast2D.new()
	ray.collision_mask = 2
	ray.collide_with_areas = true
	pipe.add_child(ray)
	var direction := Pipe.Direction.DOWN
	for _i in range(4):
		ray.target_position = Pipe.direction_to_vector[direction] * GameParameters.craft_tilesize
		ray.force_raycast_update()
		var collider = ray.get_collider()
		if collider is Pipe and GameParameters.is_buildable(collider.global_position):
			collider.connections |= Pipe.direction_opposite[direction]
		direction = Pipe.rotate_direction_skip_none(direction)
	pipe.remove_child(ray)


func _is_colliding() -> bool:
	_ray.target_position = Vector2(0, 0)
	_ray.force_shapecast_update()
	return _ray.is_colliding()


func _is_inside_bounds(p_position: Vector2):
	if type != Tile.Type.CRAFTER:
		return GameParameters.is_buildable(p_position)
	else:
		var shift = Vector2.RIGHT * (GameParameters.craft_tilesize * 0.5)
		return GameParameters.is_buildable(p_position + shift) and GameParameters.is_buildable(position - shift)
