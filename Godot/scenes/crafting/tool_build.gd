class_name BuildTool
extends Node2D


@export var type: Tile.Type
@export var modulate_valid: Color = "9cff99"
@export var modulate_invalid: Color = "ff8585"
var build_target: Node2D


@onready var _ray: ShapeCast2D = $ShapeCast2D
@onready var _sprite: Sprite2D = $Sprite2D
var _dragging := false
var _previous_build = null
var _mode := MOUSE_BUTTON_NONE


func _ready():
	$Sprite2D.texture = Tile.sprites[type]


func _input(event):
	if event is InputEventMouseMotion:
		var size = Vector2i(1, 1) if type != Tile.Type.CRAFTER else Vector2i(2, 1)
		global_position = Tile.snap_crafting(event.position, size)
		if not _is_colliding() or (type == Tile.Type.PIPE and _ray.get_collider(0) is Pipe):
			_sprite.modulate = modulate_valid
		else:
			_sprite.modulate = modulate_invalid
		if _dragging:
			if _mode == MOUSE_BUTTON_LEFT:
				_try_build(event.position)
			elif _mode == MOUSE_BUTTON_RIGHT:
				_try_remove()
	elif event is InputEventMouseButton:
		if not event.pressed or _mode == event.button_index:
			_dragging = false


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_build(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_try_remove()
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			get_viewport().set_input_as_handled()
			_previous_build = null
			_dragging = true
			_mode = event.button_index


func _try_remove():
	if not _is_colliding():
		return
	RemoveTool.try_remove(_ray.get_collider(0))


func _try_build(p_position):
	if type not in Tile.scenes:
		push_error('tried to build {0} but there is no scene for that'.format([type]))
		return

	var new_connections = 0
	if type == Tile.Type.PIPE and _previous_build is Pipe:
		var current = Tile.snap_crafting(p_position)
		var other = _previous_build.global_position
		var x_same = abs(current.x - other.x) < 1.0
		var y_same = abs(current.y - other.y) < 1.0
		if x_same and y_same:
			pass
		elif x_same and abs(current.y - other.y) < GameParameters.tilesize * 1.5:
			if current.y - other.y < 0.0:
				_previous_build.connections |= Pipe.Direction.UP
				new_connections = Pipe.Direction.DOWN
			else:
				_previous_build.connections |= Pipe.Direction.DOWN
				new_connections = Pipe.Direction.UP
		elif y_same and abs(current.x - other.x) < GameParameters.tilesize * 1.5:
			if current.x - other.x < 0.0:
				_previous_build.connections |= Pipe.Direction.LEFT
				new_connections = Pipe.Direction.RIGHT
			else:
				_previous_build.connections |= Pipe.Direction.RIGHT
				new_connections = Pipe.Direction.LEFT

	if _is_colliding():
		var collider = _ray.get_collider(0)
		if collider is Pipe:
			collider.connections |= new_connections
			collider.direction = Pipe.Direction.NONE
		_previous_build = _ray.get_collider(0)
		return

	var tile = Tile.scenes[type].instantiate()
	tile.global_position = p_position
	if type == Tile.Type.PIPE:
		tile.connections = new_connections
	build_target.add_child(tile)

	_previous_build = tile


func _is_colliding() -> bool:
	_ray.target_position = Vector2(0, 0)
	_ray.force_shapecast_update()
	return _ray.is_colliding()