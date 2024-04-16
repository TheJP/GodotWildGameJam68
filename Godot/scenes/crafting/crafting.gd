extends Node2D


@onready var _menu: MenuInGame = get_tree().get_first_node_in_group("menu_in_game")


func _ready():
	if _menu == null:
		push_error('crafting scene could not connect to menu')
		return
