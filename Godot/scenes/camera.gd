extends Camera2D


const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 3.0


@export var pan_speed: float = 1500.0


var pressed := {}
var actions: Array[StringName] = ['left', 'up', 'right', 'down']


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = maxf(zoom.x * 0.9, MIN_ZOOM) * Vector2.ONE
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = minf(zoom.x * 1.1, MAX_ZOOM) * Vector2.ONE
			get_viewport().set_input_as_handled()

	for action in actions:
		if event.is_action_pressed(action, false, true):
			pressed[action] = true
			get_viewport().set_input_as_handled()
		if event.is_action_released(action, true):
			pressed.erase(action)
			get_viewport().set_input_as_handled()


func _process(delta):
	var move = Vector2.ZERO
	if StringName('left') in pressed:
		move += Vector2.LEFT
	if StringName('up') in pressed:
		move += Vector2.UP
	if StringName('right') in pressed:
		move += Vector2.RIGHT
	if StringName('down') in pressed:
		move += Vector2.DOWN
	position += move.normalized() * (pan_speed * delta / zoom.x)
