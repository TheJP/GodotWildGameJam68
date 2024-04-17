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


func _ready():
	$Sprite2D.texture = Tile.sprites[type]


func _input(event):
	if event is InputEventMouseMotion:
		var size = Vector2i(1, 1) if type != Tile.Type.CRAFTER else Vector2i(2, 1)
		global_position = Tile.snap_crafting(event.position, size)
		_sprite.modulate = modulate_invalid if _is_colliding() else modulate_valid
		if _dragging:
			_try_build(event.position)
	elif event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = false


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			_previous_build = null
			_try_build(event.position)
			_dragging = true


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
