extends Area2D


static var _dragging = null


@export var type: Item.Type
@export var animation_speed := 3.0
var container = null
var _previous_container = null


var _tween: Tween = null
var _hovering: bool = false
var _drag_mouse_delta: Vector2

# Currently hovered drop targets.
var _hovered_targets := {}
var _previous_target = null


@onready var _ray: RayCast2D = $RayCast2D


func _ready():
	$Sprite2D.texture = Item.sprites[type]
	Ticker.timer.timeout.connect(_on_global_ticker_timeout)
	if type in Item.decay:
		var decay = Item.decay[type]
		get_tree().create_timer(decay.age, false).timeout.connect(_item_decayed.bind(decay))


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not event.pressed and _dragging == self:
			# Stop dragging.
			_dragging = null
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			_update_machine()
			var target = _closest_machine()
			if target != null and target.try_drop(self):
				container = target
		elif event.pressed and _hovering and _dragging == null:
			# Start dragging.
			if container != null and not container.try_remove():
				return
			container = null
			_previous_container = null
			_dragging = self
			if _tween != null:
				_tween.stop()
			_drag_mouse_delta = position - event.position
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			_update_machine()


func _input(event):
	if event is InputEventMouseMotion:
		if _dragging != self:
			return
		position = event.position + _drag_mouse_delta



func _on_mouse_entered():
	_hovering = true
	if _dragging == null:
		scale = Vector2(1.1, 1.1)
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_mouse_exited():
	_hovering = false
	scale = Vector2(1, 1)
	if _dragging == null:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_area_entered(area):
	if area is Machine:
		_hovered_targets[area] = null
		_update_machine()


func _on_area_exited(area):
	if area is Machine and area in _hovered_targets:
		_hovered_targets.erase(area)
		_update_machine()


func _update_machine():
	var next_target = _closest_machine() if _dragging == self else null

	if next_target != _previous_target:
		if _previous_target != null:
			_previous_target.unhover()
		if next_target != null:
			next_target.hover()
		_previous_target = next_target


func _closest_machine():
	var closest = null
	var closest_distance = INF
	for target in _hovered_targets.keys():
		var distance = position.distance_squared_to(target.position)
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
	var directions := []
	if container is CrafterSlot or container is Spawner:
		directions = [Vector2.DOWN]
	elif container is Pipe:
		directions = [Vector2.DOWN, Vector2.LEFT, Vector2.UP, Vector2.RIGHT]
	directions.shuffle()

	for direction in directions:
		_ray.target_position = direction * GameParameters.craft_tilesize
		_ray.force_raycast_update()
		var collider = _ray.get_collider()
		if collider == null or not (collider is Machine):
			continue
		if collider == _previous_container:
			continue # Do not flow back where you came from.
		if not collider.try_drop(self):
			continue

		if not container.try_remove():
			push_error('could not remove item')
		_previous_container = container
		container = collider

		if _tween != null:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "position", start_position, 0)
		_tween.tween_property(self, "position", position, 1.0 / animation_speed).set_trans(Tween.TRANS_SINE)
		break


func _item_decayed(decay):
	if decay.output.is_nothing:
		while container != null and not container.try_remove():
			await Ticker.timer.timeout # Retry next tick.
		queue_free()
	else:
		type = decay.output.type
		$Sprite2D.texture = Item.sprites[type]
