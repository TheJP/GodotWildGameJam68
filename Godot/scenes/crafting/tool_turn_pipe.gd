class_name TurnPipeTool
extends Node2D


@export var modulate_valid: Color = "9cff99"
@export var modulate_invalid: Color = "ff8585"


@onready var _ray: ShapeCast2D = $ShapeCast2D
@onready var _sprite: Sprite2D = $Sprite2D


func _ready():
	_mouse_move(get_viewport().get_mouse_position())


func _input(event):
	if event is InputEventMouseMotion:
		_mouse_move(event.position)


func _mouse_move(p_position: Vector2):
	p_position = Utility.viewport_to_world(p_position)
	global_position = Tile.snap_crafting(p_position)
	var pipe = _get_collision()
	if pipe is Pipe and GameParameters.is_buildable(pipe.global_position):
		_sprite.modulate = modulate_valid
		_sprite.rotation = Pipe.arrow_rotation[pipe.direction]
	else:
		_sprite.modulate = modulate_invalid


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			return

		get_viewport().set_input_as_handled()

		if not GameParameters.is_buildable(global_position):
			return
		var pipe = _get_collision()
		if pipe is Pipe:
			if event.button_index == MOUSE_BUTTON_LEFT:
				pipe.direction = Pipe.rotate_direction_skip_none(pipe.direction)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				pipe.direction = Pipe.Direction.NONE
			_sprite.rotation = Pipe.arrow_rotation[pipe.direction]


func _get_collision() -> Node2D:
	_ray.target_position = Vector2(0, 0)
	_ray.force_shapecast_update()
	if not _ray.is_colliding():
		return null
	return _ray.get_collider(0)
