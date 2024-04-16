extends Node2D


@export var type: Tile.Type


@onready var _ray: ShapeCast2D = $ShapeCast2D


func _ready():
	$Sprite2D.texture = Tile.sprites[type]


func _input(event):
	if event is InputEventMouseMotion:
		var size = Vector2i(1, 1) if type != Tile.Type.CRAFTER else Vector2i(2, 1)
		global_position = Tile.snap_crafting(event.global_position, size)
	elif event is InputEventMouseButton:
		if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
			return
		if type not in Tile.scenes:
			push_error('tried to build {} but there is no scene for that'.format(type))
			return
		await get_tree().physics_frame
		_ray.target_position = Vector2(0, 0)
		_ray.force_shapecast_update()
		if _ray.is_colliding():
			print('collision') # TODO: Does not work yet
			return

		var tile = Tile.scenes[type].instantiate()
		tile.global_position = event.global_position
		get_parent().add_child(tile)
