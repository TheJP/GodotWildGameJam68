extends Control


enum Type {
	MAIN,
	TRASH_CAN,
	ARROW,
	INTERSECTION,
}


class Tutorial:
	var text: String
	var video: Resource
	func _init(p_text: String, p_video: Resource):
		text = p_text
		video = p_video


static var _tutorials := {
	Type.MAIN: [
		Tutorial.new('Build a factory to craft items.', preload("res://video/tutorial_1.ogv")),
		Tutorial.new('Drag pipes to make connections.', preload("res://video/tutorial_2.ogv")),
		Tutorial.new('Equip your fighters to defend against attacking monsters.', preload("res://video/tutorial_3.ogv")),
	] as Array[Tutorial], # <- Without this we get an error when assigned to _tutorial.
	Type.TRASH_CAN: [
		Tutorial.new('{0} {1}'.format([
			'Add [color=white]Trash Cans  ([img]res://assets/trash_can.png[/img])[/color]',
			'for overflow\nor drop items into them by hand.',
		]), preload("res://video/tutorial_trash_1.ogv")),
	] as Array[Tutorial],
	Type.ARROW: [
		Tutorial.new('{0} {1}'.format([
			'Use the [color=white]Arrow  ([img]res://assets/arrow.png[/img])[/color]',
			'to make\nitems flow in that direction.',
		]), preload("res://video/tutorial_arrow_1.ogv")),
		Tutorial.new(
			'Use [u]left click[/u] to turn the arrow and [u]right click[/u] to remove it.',
			preload("res://video/tutorial_arrow_2.ogv")),
	] as Array[Tutorial],
	Type.INTERSECTION: [
		Tutorial.new('{0} {1}'.format([
			'[color=white]Intersections  ( [img]res://assets/pipes/pipe_intersection.png[/img] )[/color]',
			'allow\nitem streams to cross.'
		]), preload('res://video/tutorial_intersection_1.ogv')),
	] as Array[Tutorial],
}


var _shown_tutorials := {
	Type.MAIN: true,
}


var _tutorial: Array[Tutorial] = _tutorials[Type.MAIN]
var _current_index := 0
var _hovered = null


func _ready():
	visible = GameParameters.is_tutorial
	get_tree().paused = visible
	if not GameParameters.is_tutorial:
		queue_free()
		return
	else:
		%NextButton.grab_focus()
		AudioController.get_player('CalmMenuLoop').play()
	_update_tutorial()

	# Setup tutorial hooks.
	await get_tree().process_frame

	var _menu: MenuInGame = get_tree().get_first_node_in_group('menu_in_game')
	if _menu == null:
		push_error('tutorial could not connect to menu')
		return

	#_menu.start_default_tool.connect(_before_tool_switch)
	#_menu.start_build_crafter.connect(_start_building.bind(Tile.Type.CRAFTER))
	#_menu.start_build_pipe.connect(_start_building.bind(Tile.Type.PIPE))
	_menu.start_build_intersection.connect(show_tutorial.bind(Type.INTERSECTION))
	_menu.start_pipe_turn.connect(show_tutorial.bind(Type.ARROW))
	_menu.start_build_trash.connect(show_tutorial.bind(Type.TRASH_CAN))
	#_menu.start_remove.connect(_start_remove)


func show_tutorial(type: Type):
	if type not in _tutorials:
		push_error('tried to show unknown tutorial "{0}"'.format([Type.values()[type]]))
		return
	if visible or not GameParameters.is_tutorial or type in _shown_tutorials:
		return

	_tutorial = _tutorials[type]
	_current_index = 0
	_shown_tutorials[type] = true

	visible = true
	get_tree().paused = true
	%NextButton.grab_focus()
	AudioController.get_player('CalmMenuLoop').play()

	_update_tutorial()


func _on_back_button_pressed():
	_current_index = clampi(_current_index - 1, 0, len(_tutorial) - 1)
	AudioController.get_player("MenuPressSound").play()
	_update_tutorial()


func _on_next_button_pressed():
	AudioController.get_player("MenuPressSound").play()
	if _current_index + 1 >= len(_tutorial):
		visible = false
		get_tree().paused = false
		AudioController.get_player('CalmMenuLoop').stop()
	else:
		_current_index = clampi(_current_index + 1, 0, len(_tutorial) - 1)
		_update_tutorial()


func _update_tutorial():
	%Text.text = _tutorial[_current_index].text
	%VideoStreamPlayer.stream = _tutorial[_current_index].video
	%VideoStreamPlayer.play()
	%BackButton.visible = _current_index > 0
	%NextButton.text = 'Next' if _current_index + 1 < len(_tutorial) else 'Close'
	%PageNumber.text = '{0} / {1}'.format([_current_index + 1, len(_tutorial)])


func _button_hovered(control: String):
	if _hovered != control:
		_hovered = control
		AudioController.get_player("MenuHoverSound").play()


func _button_unhovered():
	_hovered = null
