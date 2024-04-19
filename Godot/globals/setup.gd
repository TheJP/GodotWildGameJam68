extends Node


var _hand = preload('res://assets/hand_open.png')
var _grab = preload('res://assets/hand_closed.png')


func _ready():
	Input.set_custom_mouse_cursor(_hand, Input.CURSOR_CAN_DROP)
	Input.set_custom_mouse_cursor(_grab, Input.CURSOR_DRAG)
