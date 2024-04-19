class_name AudioController
extends Node


static var controller: AudioController


func _ready():
	controller = self


static func get_player(path: NodePath) -> AudioStreamPlayer:
	return controller.get_node(path) as AudioStreamPlayer
