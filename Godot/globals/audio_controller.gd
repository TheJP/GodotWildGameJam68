extends Node


var _scene = preload('res://scenes/audio_controller.tscn')
var _controller: Node


func get_player(path: NodePath) -> AudioStreamPlayer:
	return _controller.get_node(path)


func _ready():
	_controller = _scene.instantiate()
	add_child(_controller)
	get_player("Level1Loop").play()
