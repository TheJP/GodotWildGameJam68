class_name BuildTool
extends Node2D


@export var type: Tile.Type
@export var modulate_valid: Color = "9cff99"
@export var modulate_invalid: Color = "ff8585"
var build_target: Node2D


@onready var _ray: ShapeCast2D = $ShapeCast2D
@onready var _sprite: Sprite2D = $Sprite2D
var _dragging := false


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
			_try_build(event.position)
			_dragging = true


func _try_build(p_position):
	if type not in Tile.scenes:
		push_error('tried to build {0} but there is no scene for that'.format([type]))
		return
	if _is_colliding():
		return

	var tile = Tile.scenes[type].instantiate()
	tile.global_position = p_position
	build_target.add_child(tile)


func _is_colliding() -> bool:
	_ray.target_position = Vector2(0, 0)
	_ray.force_shapecast_update()
	return _ray.is_colliding()
