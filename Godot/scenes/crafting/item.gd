class_name ItemEntity
extends Area2D


static var dragging = null


@export var type: Item.Type
@export var animation_speed := 3.0
var container = null
var _previous_container = null
var _intersection_direction := Pipe.Direction.NONE


var _tween: Tween = null
var _hovering: bool = false
var _drag_mouse_delta: Vector2

# Currently hovered drop targets.
var _hovered_targets := {}
var _previous_target = null


@onready var _ray: RayCast2D = $RayCast2D
var effect = null


func _ready():
	$Sprite2D.texture = Item.sprites[type]
	set_effect(Item.effects[type])
	Ticker.timer.timeout.connect(_on_global_ticker_timeout)
	if type in Item.decay:
		var decay = Item.decay[type]
		get_tree().create_timer(decay.age, false).timeout.connect(_item_decayed.bind(decay))

func set_effect(_effect):
	if effect != null:
		effect.queue_free()
	if(_effect != null):
		effect = _effect.instantiate()
		self.add_child(effect)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not event.pressed and dragging == self:
			# Stop dragging.
			dragging = null
			Input.set_default_cursor_shape(Input.CURSOR_CAN_DROP)
			_update_target()
			var target = _closest_target()
			if target != null and target.try_drop(self):
				container = target
		elif event.pressed and _hovering and dragging == null:
			# Start dragging.
			if container != null and not container.try_remove():
				return
			container = null
			_previous_container = null
			dragging = self
			if _tween != null:
				_tween.stop()
			_drag_mouse_delta = position - event.position
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			_update_target()


func _input(event):
	if event is InputEventMouseMotion:
		if dragging != self:
			return
		position = event.position + _drag_mouse_delta



func _on_mouse_entered():
	_hovering = true
	if dragging == null and Tool.current_type == Tool.Type.DEFAULT:
		scale = Vector2(1.1, 1.1)
		Input.set_default_cursor_shape(Input.CURSOR_CAN_DROP)


func _on_mouse_exited():
	_hovering = false
	scale = Vector2(1, 1)
	if dragging == null or Tool.current_type == Tool.Type.DEFAULT:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_area_entered(area):
	if (area is Machine or area is Friendly):
		_hovered_targets[area] = null
		_update_target()


func _on_area_exited(area):
	if (area is Machine or area is Friendly) and area in _hovered_targets:
		_hovered_targets.erase(area)
		_update_target()


func _update_target():
	var next_target = _closest_target() if dragging == self else null

	if next_target != _previous_target:
		if _previous_target != null:
			_previous_target.unhover()
		if next_target != null:
			next_target.hover()
		_previous_target = next_target


func _closest_target():
	var closest = null
	var closest_distance = INF
	for target in _hovered_targets.keys():
		var distance = global_position.distance_squared_to(target.global_position)
		if distance < closest_distance:
			closest = target
			closest_distance = distance

	return closest

func _on_global_ticker_timeout():
	_flow()

func _flow():
	# Ignore items that are being dragged or are not "in the system".
	if container == null:
		return
	if container is CrafterSlot and container.is_waiting_for_craft:
		return
	if _tween != null and _tween.is_running():
		return

	var start_position = position
	for target in _find_flow_targets():
		if not target.machine.try_drop(self):
			continue
		if not container.try_remove():
			push_error('could not remove item')

		if container is Pipe:
			container.next_output = Pipe.rotate_direction_skip_none(target.direction)
		_previous_container = container
		container = target.machine

		if target.machine is Pipe and target.machine.is_intersection:
			_intersection_direction = target.direction
		else:
			_intersection_direction = Pipe.Direction.NONE

		if _tween != null:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "position", start_position, 0)
		_tween.tween_property(self, "position", position, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		break


class FlowTarget:
	var machine: Machine
	var direction: Pipe.Direction

	func _init(p_machine: Machine, p_direction: Pipe.Direction):
		machine = p_machine
		direction = p_direction


# Finds all valid flow target and returns them in order of flow priority.
func _find_flow_targets() -> Array[FlowTarget]:
	var result: Array[FlowTarget] = []
	var trash_cans: Array[FlowTarget] = []

	var directions := []
	if container is CrafterSlot or container is Spawner:
		directions = [Pipe.Direction.DOWN]
	elif container is Pipe:
		if not container.is_intersection or _intersection_direction == Pipe.Direction.NONE:
			directions = container.get_flow_directions()
		else:
			directions = [_intersection_direction]

	for direction in directions:
		var trajectory: Vector2 = Pipe.direction_to_vector[direction]
		_ray.target_position = trajectory * GameParameters.craft_tilesize
		_ray.force_raycast_update()
		var collider = _ray.get_collider()
		if collider == null or not (collider is Machine):
			continue
		if collider == _previous_container:
			continue # Do not flow back where you came from.

		if collider is Pipe:
			if collider.direction != Pipe.Direction.NONE:
				if (trajectory + collider.get_pipe_trajectory()).length_squared() < 0.001:
					continue # Do not flow into pipe that points towards us.
			if Pipe.direction_opposite[direction] & collider.connections == 0:
				continue # Do not flow into pipe that is not connected with us.

		if collider is TrashCan:
			trash_cans.append(FlowTarget.new(collider, direction))
		else:
			result.append(FlowTarget.new(collider, direction))

	result.append_array(trash_cans)
	return result


func _item_decayed(decay):
	if decay.output.is_nothing:
		while container != null and not container.try_remove():
			await Ticker.timer.timeout # Retry next tick.
		queue_free()
	else:
		type = decay.output.type
		$Sprite2D.texture = Item.sprites[type]
		set_effect(Item.effects[type])
