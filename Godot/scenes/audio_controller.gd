class_name AudioController
extends Node


static var controller: AudioController


func _ready():
	controller = self


func get_player(path: NodePath) -> AudioStreamPlayer:
	return get_node(path) as AudioStreamPlayer
