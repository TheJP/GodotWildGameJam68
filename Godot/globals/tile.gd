class_name Tile

enum Type {
	CRAFTER,
	PIPE,
	SPAWNER,
	DISPENSER,
	TRASH_CAN,
}


static var sprites := {
	Type.CRAFTER: preload('res://assets/crafter_combined.png'),
	Type.PIPE: preload('res://assets/pipes/pipe_urdl.png'),
	Type.SPAWNER: preload('res://assets/spawner.png'),
	Type.DISPENSER: preload('res://assets/spawner.png'), # TODO
	Type.TRASH_CAN: preload('res://assets/trash_can.png'),
}
