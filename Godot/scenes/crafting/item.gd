extends Area2D


static var _dragging = null


@export var type: Item.Type
var _hovering: bool = false
var _drag_mouse_delta: Vector2


func _ready():
	$Sprite2D.texture = Item.sprites[type]


func _process(delta):
	pass


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not event.pressed and _dragging == self:
			_dragging = null
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		elif event.pressed and _hovering and _dragging == null:
			_dragging = self
			_drag_mouse_delta = position - event.position
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	if event is InputEventMouseMotion:
		if _dragging == self:
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
