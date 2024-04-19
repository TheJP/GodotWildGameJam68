class_name AudioController
extends Node


static var controller: AudioController


static func get_player(path: NodePath) -> AudioStreamPlayer:
	return controller._get_player(path)


func _ready():
	controller = self
	await get_tree().process_frame
	controller.get_player("Level1Loop").play()


func _get_player(path: NodePath) -> AudioStreamPlayer:
	return get_node(path) as AudioStreamPlayer
