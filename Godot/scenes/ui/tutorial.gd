extends Control


static var _texts: Array[String] = [
	'Build a factory to craft items.',
	'Drag pipes to make connections.',
	'Equip your fighters to defend against attacking monsters.'
]


static var _videos: Array = [
	preload("res://video/tutorial_1.ogv"),
	preload("res://video/tutorial_2.ogv"),
	preload("res://video/tutorial_3.ogv"),
]


var _current_index := 0


func _ready():
	assert(len(_texts) == len(_videos), 'invalid tutorial setup')
	visible = GameParameters.is_tutorial
	get_tree().paused = visible
	if not GameParameters.is_tutorial:
		queue_free()
		return
	_update_tutorial()


func _on_back_button_pressed():
	_current_index = clampi(_current_index - 1, 0, len(_videos) - 1)
	_update_tutorial()


func _on_next_button_pressed():
	if _current_index + 1 >= len(_videos):
		visible = false
		get_tree().paused = false
	else:
		_current_index = clampi(_current_index + 1, 0, len(_videos) - 1)
		_update_tutorial()


func _update_tutorial():
	%Text.text = _texts[_current_index]
	%VideoStreamPlayer.stream = _videos[_current_index]
	%VideoStreamPlayer.play()
	%BackButton.visible = _current_index > 0
	%NextButton.text = 'Next' if _current_index + 1 < len(_videos) else 'Close'
	%PageNumber.text = '{0} / {1}'.format([_current_index + 1, len(_videos)])
