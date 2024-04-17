class_name BuildTool
extends Node2D


@export var type: Tile.Type
@export var modulate_valid: Color = "9cff99"
@export var modulate_invalid: Color = "ff8585"
var build_target: Node2D


@onready var _ray: ShapeCast2D = $ShapeCast2D
@onready var _sprite: Sprite2D = $Sprite2D


func _ready():
	$Sprite2D.texture = Tile.sprites[type]


func _input(event):
	if event is InputEventMouseMotion:
		var size = Vector2i(1, 1) if type != Tile.Type.CRAFTER else Vector2i(2, 1)
		global_position = Tile.snap_crafting(event.position, size)
		_sprite.modulate = modulate_invalid if _is_colliding() else modulate_valid


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
			return

		get_viewport().set_input_as_handled()

		if type not in Tile.scenes:
			push_error('tried to build {} but there is no scene for that'.format(type))
			return
		if _is_colliding():
			return

		var tile = Tile.scenes[type].instantiate()
		tile.global_position = event.position
		build_target.add_child(tile)


func _is_colliding() -> bool:
	_ray.target_position = Vector2(0, 0)
	_ray.force_shapecast_update()
	return _ray.is_colliding()
