class_name Pipe
extends Machine


enum Direction {
	NONE  =     0b1,
	DOWN  =    0b10,
	LEFT  =   0b100,
	UP    =  0b1000,
	RIGHT = 0b10000,
}


static var CONNECTIONS_ALL = Pipe.Direction.DOWN | Pipe.Direction.LEFT | Pipe.Direction.UP | Pipe.Direction.RIGHT


static var arrow_rotation := {
	Direction.NONE: 0,
	Direction.DOWN: 0,
	Direction.LEFT: PI * 0.5,
	Direction.UP: PI,
	Direction.RIGHT: PI * 1.5,
}


static var direction_to_vector := {
	Direction.NONE: Vector2.ZERO,
	Direction.DOWN: Vector2.DOWN,
	Direction.LEFT: Vector2.LEFT,
	Direction.UP: Vector2.UP,
	Direction.RIGHT: Vector2.RIGHT,
}


static var direction_opposite := {
	Direction.NONE: Direction.NONE,
	Direction.DOWN: Direction.UP,
	Direction.LEFT: Direction.RIGHT,
	Direction.UP: Direction.DOWN,
	Direction.RIGHT: Direction.LEFT,
}


static var _sprites := {
	0: preload('res://assets/pipes/pipe_.png'),
	Direction.UP: preload('res://assets/pipes/pipe_u.png'),
	Direction.RIGHT: preload('res://assets/pipes/pipe_r.png'),
	Direction.DOWN: preload('res://assets/pipes/pipe_d.png'),
	Direction.LEFT: preload('res://assets/pipes/pipe_l.png'),
	(Direction.UP | Direction.RIGHT): preload('res://assets/pipes/pipe_ur.png'),
	(Direction.UP | Direction.DOWN): preload('res://assets/pipes/pipe_ud.png'),
	(Direction.UP | Direction.LEFT): preload('res://assets/pipes/pipe_ul.png'),
	(Direction.RIGHT | Direction.DOWN): preload('res://assets/pipes/pipe_rd.png'),
	(Direction.RIGHT | Direction.LEFT): preload('res://assets/pipes/pipe_rl.png'),
	(Direction.DOWN | Direction.LEFT): preload('res://assets/pipes/pipe_dl.png'),
	(Direction.UP | Direction.RIGHT | Direction.DOWN): preload('res://assets/pipes/pipe_urd.png'),
	(Direction.UP | Direction.RIGHT | Direction.LEFT): preload('res://assets/pipes/pipe_url.png'),
	(Direction.UP | Direction.DOWN | Direction.LEFT): preload('res://assets/pipes/pipe_udl.png'),
	(Direction.RIGHT | Direction.DOWN | Direction.LEFT): preload('res://assets/pipes/pipe_rdl.png'),
	(Direction.UP | Direction.RIGHT | Direction.DOWN | Direction.LEFT): preload('res://assets/pipes/pipe_urdl.png'),
}
static var _sprite_intersection := preload("res://assets/pipes/pipe_intersection.png")


var item = null
@export var direction := Direction.NONE
var next_output := Direction.RIGHT
var connections = 0
var is_intersection := false


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _arrow: Sprite2D = $Sprite2DArrow
@onready var _ray: RayCast2D = $RayCast2D
var _last_direction = -1


static func rotate_direction(p_direction: Pipe.Direction) -> Pipe.Direction:
	var numerical: int = p_direction << 1
	if numerical > Pipe.Direction.values().max():
		return Pipe.Direction.NONE
	return numerical as Pipe.Direction


static func rotate_direction_skip_none(p_direction: Pipe.Direction) -> Pipe.Direction:
	var numerical: int = p_direction << 1
	if numerical > Pipe.Direction.values().max():
		return Pipe.Direction.DOWN
	return numerical as Pipe.Direction


func _ready():
	global_position = Tile.snap_crafting(global_position)


func _process(_delta):
	var sprite = _sprites[connections] if not is_intersection else _sprite_intersection
	if _sprite.texture != sprite:
		_sprite.texture = sprite

	if _last_direction == direction:
		return
	_last_direction = direction

	if direction == Direction.NONE:
		_arrow.hide()
	else:
		_arrow.show()
		_arrow.rotation = arrow_rotation[direction]


func get_pipe_trajectory() -> Vector2:
	return direction_to_vector[direction]


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


func get_flow_directions() -> Array:
	if direction != Pipe.Direction.NONE:
		return [direction] if direction & connections > 0 else []
	else:
		var directions: Array[Direction] = []
		var d := next_output
		for _i in range(4):
			if d & connections > 0:
				directions.append(d)
			d = Pipe.rotate_direction_skip_none(d)
		return directions


func setup_initial_connections():
	var d := Direction.DOWN
	for _i in range(4):
		_ray.target_position = direction_to_vector[d] * GameParameters.craft_tilesize
		_ray.force_raycast_update()
		if _ray.is_colliding():
			connections |= d
		d = Pipe.rotate_direction_skip_none(d)
