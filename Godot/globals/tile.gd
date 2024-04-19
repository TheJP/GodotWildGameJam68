class_name Tile

enum Type {
	CRAFTER,
	PIPE,
	SPAWNER,
	DISPENSER,
	TRASH_CAN,
}


static var sprites := {
	Type.CRAFTER: preload('res://assets/crafter.png'),
	Type.PIPE: preload('res://assets/pipes/pipe_urdl.png'),
	Type.SPAWNER: preload('res://assets/spawner.png'),
	Type.DISPENSER: preload('res://assets/dispenser.png'),
	Type.TRASH_CAN: preload('res://assets/trash_can.png'),
}
static var sprite_intersection := preload('res://assets/pipes/pipe_intersection.png')


static var scenes := {
	Type.CRAFTER: preload('res://scenes/crafting/crafter.tscn'),
	Type.PIPE: preload('res://scenes/crafting/pipe.tscn'),
	Type.TRASH_CAN: preload('res://scenes/crafting/trash_can.tscn'),
}


static func snap_fighting(position: Vector2, size: Vector2i = Vector2i(1, 1)) -> Vector2:
	return _snap(GameParameters.craft_tilesize, position, size)


static func snap_crafting(position: Vector2, size: Vector2i = Vector2i(1, 1)) -> Vector2:
	return _snap(GameParameters.tilesize, position, size)


static func _snap(tilesize: float, position: Vector2, size: Vector2i = Vector2i(1, 1)) -> Vector2:
	assert(size.x <= 2 and size.y <= 2, "not implemented")
	var translation = (tilesize * 0.5) * Vector2(
		1 if size.x == 1 else 0,
		1 if size.y == 1 else 0,
	)

	position -= translation
	position = position.snapped(Vector2.ONE * tilesize)
	return position + translation
