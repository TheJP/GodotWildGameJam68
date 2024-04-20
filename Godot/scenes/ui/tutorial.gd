extends Control


static var _texts: Array[String] = [
	'Build a factory to craft items.',
]


static var _videos: Array = [
	preload("res://video/tutorial_1.ogv"),
]


var _current_index := 0


func _ready():
	assert(len(_texts) == len(_videos), 'invalid tutorial setup')
	#GameParameters.is_tutorial = true # TODO: remove
	visible = GameParameters.is_tutorial
	get_tree().paused = visible
	if not GameParameters.is_tutorial:
		queue_free()
		return
	_update_tutorial()


func _update_tutorial():
	%Text.text = _texts[_current_index]
	%VideoStreamPlayer.stream = _videos[_current_index]
	%VideoStreamPlayer.play()
	%BackButton.visible = _current_index > 0
	%PageNumber.text = '{0} / {1}'.format([_current_index + 1, len(_videos)])

