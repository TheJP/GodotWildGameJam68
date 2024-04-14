extends Area2D


static var _dragging = null


@export var type: Item.Type
var container = null
var _hovering: bool = false
var _drag_mouse_delta: Vector2

# Currently hovered drop targets.
var _hovered_targets := {}
var _previous_target = null


func _ready():
	$Sprite2D.texture = Item.sprites[type]


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not event.pressed and _dragging == self:
			_dragging = null
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			update_drop_target()
			if container != null:
				container.remove_item()
			var target = closest_drop_target()
			if target != null and target.try_drop(self):
				container = target
			else:
				container = null
		elif event.pressed and _hovering and _dragging == null:
			if container != null and not container.try_start_remove():
				return
			_dragging = self
			_drag_mouse_delta = position - event.position
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			update_drop_target()
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
	if area is DropTarget:
		_hovered_targets[area] = null
		update_drop_target()


func _on_area_exited(area):
	if area is DropTarget and area in _hovered_targets:
		_hovered_targets.erase(area)
		update_drop_target()


func update_drop_target():
	var next_target = closest_drop_target() if _dragging == self else null

	if next_target != _previous_target:
		if _previous_target != null:
			_previous_target.unhover()
		if next_target != null:
			next_target.hover()
		_previous_target = next_target


func closest_drop_target():
	var closest = null
	var closest_distance = INF
	for target in _hovered_targets.keys():
		var distance = position.distance_squared_to(target.position)
		if distance < closest_distance:
			closest = target
			closest_distance = distance

	return closest
