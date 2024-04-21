extends Node2D


@onready var _build_tool_scene = preload('res://scenes/crafting/tool_build.tscn')
@onready var _remove_tool_scene = preload('res://scenes/crafting/tool_remove.tscn')
@onready var _turn_pipe_tool_scene = preload('res://scenes/crafting/tool_turn_pipe.tscn')
@onready var _machines_and_items: Node2D = $MachinesAndItems
@onready var _build_tools: Node2D = $BuildTools


var _current_tool = null


func _ready():
	await get_tree().process_frame

	for child in $MachinesAndItems.get_children():
		if child is Pipe:
			child.setup_initial_connections()

	var _menu: MenuInGame = get_tree().get_first_node_in_group('menu_in_game')
	if _menu == null:
		push_error('crafting scene could not connect to menu')
		return

	_menu.start_default_tool.connect(_before_tool_switch)
	_menu.start_build_crafter.connect(_start_building.bind(Tile.Type.CRAFTER))
	_menu.start_build_pipe.connect(_start_building.bind(Tile.Type.PIPE))
	_menu.start_build_intersection.connect(_start_building.bind(Tile.Type.PIPE, true))
	_menu.start_pipe_turn.connect(_start_pipe_turn)
	_menu.start_build_trash.connect(_start_building.bind(Tile.Type.TRASH_CAN))
	_menu.start_remove.connect(_start_remove)


func _start_building(type: Tile.Type, is_intersection := false):
	assert(type == Tile.Type.PIPE or not is_intersection, 'is_intersection=true is only implemented for pipes')
	_before_tool_switch()
	Tool.current_type = Tool.Type.BUILD
	_current_tool = _build_tool_scene.instantiate()
	_current_tool.type = type
	_current_tool.build_target = _machines_and_items
	_current_tool.is_intersection = is_intersection
	_build_tools.add_child(_current_tool)


func _start_pipe_turn():
	_before_tool_switch()
	Tool.current_type = Tool.Type.ARROW
	_current_tool = _turn_pipe_tool_scene.instantiate()
	_build_tools.add_child(_current_tool)


func _start_remove():
	_before_tool_switch()
	Tool.current_type = Tool.Type.REMOVE
	_current_tool = _remove_tool_scene.instantiate()
	_build_tools.add_child(_current_tool)


func _before_tool_switch():
	AudioController.get_player("MenuPressSound").play()
	if _current_tool != null:
		_current_tool.queue_free()
		_current_tool = null
		Tool.current_type = Tool.Type.DEFAULT
