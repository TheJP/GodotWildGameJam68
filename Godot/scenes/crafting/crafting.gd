extends Node2D


@onready var _menu: MenuInGame = get_tree().get_first_node_in_group("menu_in_game")
@onready var _build_tool_scene = preload('res://scenes/crafting/build_tool.tscn')


var _current_tool = null


func _ready():
	if _menu == null:
		push_error('crafting scene could not connect to menu')
		return

	_menu.start_default_tool.connect(_before_tool_switch)
	_menu.start_build_crafter.connect(_start_building.bind(Tile.Type.CRAFTER))
	_menu.start_build_pipe.connect(_start_building.bind(Tile.Type.PIPE))
	_menu.start_build_trash.connect(_start_building.bind(Tile.Type.TRASH_CAN))
	_menu.start_remove.connect(_before_tool_switch)


func _start_building(type: Tile.Type):
	_before_tool_switch()
	_current_tool = _build_tool_scene.instantiate()
	_current_tool.type = type
	add_child(_current_tool)


func _before_tool_switch():
	if _current_tool != null:
		_current_tool.queue_free()
		_current_tool = null
