extends Node2D


@onready var _build_tool_scene = preload('res://scenes/crafting/build_tool.tscn')
@onready var _remove_tool_scene = preload('res://scenes/crafting/remove_tool.tscn')
@onready var _machines_and_items: Node2D = $MachinesAndItems
@onready var _build_tools: Node2D = $BuildTools


var _current_tool = null


func _ready():
	await get_tree().process_frame
	var _menu = get_tree().get_first_node_in_group("menu_in_game")
	if _menu == null:
		push_error('crafting scene could not connect to menu')
		return

	_menu.start_default_tool.connect(_before_tool_switch)
	_menu.start_build_crafter.connect(_start_building.bind(Tile.Type.CRAFTER))
	_menu.start_build_pipe.connect(_start_building.bind(Tile.Type.PIPE))
	_menu.start_build_trash.connect(_start_building.bind(Tile.Type.TRASH_CAN))
	_menu.start_remove.connect(_start_remove)


func _start_building(type: Tile.Type):
	_before_tool_switch()
	_current_tool = _build_tool_scene.instantiate()
	_current_tool.type = type
	_current_tool.build_target = _machines_and_items
	_build_tools.add_child(_current_tool)


func _start_remove():
	_before_tool_switch()
	_current_tool = _remove_tool_scene.instantiate()
	_build_tools.add_child(_current_tool)


func _before_tool_switch():
	if _current_tool != null:
		_current_tool.queue_free()
		_current_tool = null
