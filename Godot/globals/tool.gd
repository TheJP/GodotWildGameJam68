extends Node


enum Type {
	DEFAULT,
	BUILD,
	ARROW,
	REMOVE,
}


@onready var current_type = Type.DEFAULT
