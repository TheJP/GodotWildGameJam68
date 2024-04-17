class_name TurnPipeTool
extends Node2D


@export var modulate_valid: Color = "9cff99"
@export var modulate_invalid: Color = "ff8585"


@onready var _ray: ShapeCast2D = $ShapeCast2D
@onready var _sprite: Sprite2D = $Sprite2D


func _rotate_direction(direction: Pipe.Direction) -> Pipe.Direction:
	direction += 1
	if direction > Pipe.Direction.values().max():
		direction = Pipe.Direction.NONE
	return direction


func _input(event):
	if event is InputEventMouseMotion:
		global_position = Tile.snap_crafting(event.position)
		var modulate = modulate_invalid
		var pipe = _get_collision()
		if pipe is Pipe:
			_sprite.modulate = modulate_valid
			var direction := _rotate_direction(pipe.direction)
			_sprite.rotation = Pipe.arrow_rotation[direction]
		else:
			_sprite.modulate = modulate_invalid


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
			return

		get_viewport().set_input_as_handled()

		var pipe = _get_collision()
		if pipe is Pipe:
			pipe.direction = _rotate_direction(pipe.direction)


func _get_collision() -> Node2D:
	_ray.target_position = Vector2(0, 0)
	_ray.force_shapecast_update()
	return _ray.get_collider(0)
