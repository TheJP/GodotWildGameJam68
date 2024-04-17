class_name Pipe
extends Machine


enum Direction {
	NONE,
	UP,
	RIGHT,
	DOWN,
	LEFT,
}


static var _arrow_rotation := {
	Direction.NONE: 0,
	Direction.DOWN: 0,
	Direction.LEFT: PI * 0.5,
	Direction.UP: PI,
	Direction.RIGHT: PI * 1.5,
}


static var _direction_to_vector := {
	Direction.NONE: Vector2.ZERO,
	Direction.DOWN: Vector2.DOWN,
	Direction.LEFT: Vector2.LEFT,
	Direction.UP: Vector2.UP,
	Direction.RIGHT: Vector2.RIGHT,
}


var item = null
@export var direction := Direction.NONE


@onready var _arrow: Sprite2D = $Sprite2DArrow


func _ready():
	global_position = Tile.snap_crafting(global_position)
	if direction != Direction.NONE:
		_arrow.show()
		_arrow.rotation = _arrow_rotation[direction]


func get_pipe_trajectory() -> Vector2:
	return _direction_to_vector[direction]


func hover():
	scale = Vector2(1.1, 1.1)


func unhover():
	scale = Vector2(1, 1)


func destroy():
	if item != null:
		item.queue_free()
	queue_free()


func try_drop(p_item: Node2D) -> bool:
	if item != null:
		return false
	else:
		item = p_item
		item.global_position = global_position
		return true


func try_remove() -> bool:
	if item == null:
		push_warning('try_remove() called on empty pipe')
		return true
	else:
		item = null
		return true
