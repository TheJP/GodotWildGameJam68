class_name MenuInGame
extends MarginContainer


static var _selected_option: Button


signal start_default_tool()
signal start_build_crafter()
signal start_build_pipe()
signal start_build_intersection()
signal start_pipe_turn()
signal start_build_trash()
signal start_remove()


@export var hover_color = Color(0.757, 0.851, 0.949)
@export var selected_color = Color(0.565, 0.620, 0.867)


var _options: Array[Button] = []


func _ready():
	_options = [
		%DefaultButton,
		%CrafterButton,
		%PipeButton,
		%IntersectionButton,
		%ArrowButton,
		%TrashButton,
		%DeleteButton,
	]

	%DefaultButton.pressed.connect(_on_button_pressed.bind(%DefaultButton, start_default_tool))
	%CrafterButton.pressed.connect(_on_button_pressed.bind(%CrafterButton, start_build_crafter))
	%PipeButton.pressed.connect(_on_button_pressed.bind(%PipeButton, start_build_pipe))
	%IntersectionButton.pressed.connect(_on_button_pressed.bind(%IntersectionButton, start_build_intersection))
	%ArrowButton.pressed.connect(_on_button_pressed.bind(%ArrowButton, start_pipe_turn))
	%TrashButton.pressed.connect(_on_button_pressed.bind(%TrashButton, start_build_trash))
	%DeleteButton.pressed.connect(_on_button_pressed.bind(%DeleteButton, start_remove))

	for option in _options:
		option.pivot_offset = option.size * 0.5
		option.mouse_entered.connect(_hover.bind(option))
		option.mouse_exited.connect(_unhover.bind(option))

	_selected_option = %DefaultButton
	_selected_option.set_process_shortcut_input(false)
	_update_color(%DefaultButton)


func _on_button_pressed(p_option: Button, start_signal: Signal):
	if _selected_option == p_option:
		return
	_selected_option.set_process_shortcut_input(true)
	p_option.set_process_shortcut_input(false)
	_selected_option = p_option
	for option in _options:
		_update_color(option)
	start_signal.emit()
	get_viewport().set_input_as_handled()


func _hover(option: Button):
	option.scale = Vector2(1.2, 1.2)
	_update_color(option, true)


func _unhover(option: Button):
	option.scale = Vector2(1, 1)
	_update_color(option)


func _update_color(option: Button, is_hovered := false):
	var color = hover_color if is_hovered else (
		selected_color if option == _selected_option else
		Color.TRANSPARENT)
	_set_panel_color(option.get_parent_control().get_parent_control(), color)


func _set_panel_color(panel: PanelContainer, color: Color):
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = color
	panel.add_theme_stylebox_override("panel", style)


func _on_settings_button_pressed():
	var event = InputEventAction.new()
	event.action = 'ui_menu'
	event.pressed = true
	Input.parse_input_event(event)
