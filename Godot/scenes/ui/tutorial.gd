extends Control


class Tutorial:
	var text: String
	var video: Resource
	func _init(p_text: String, p_video: Resource):
		text = p_text
		video = p_video


static var _tutorials := {
	'main': [
		Tutorial.new('Build a factory to craft items.', preload("res://video/tutorial_1.ogv")),
		Tutorial.new('Drag pipes to make connections.', preload("res://video/tutorial_2.ogv")),
		Tutorial.new('Equip your fighters to defend against attacking monsters.', preload("res://video/tutorial_3.ogv")),
	] as Array[Tutorial]
}


var _tutorial: Array[Tutorial] = _tutorials['main']
var _current_index := 0


func _ready():
	visible = GameParameters.is_tutorial
	get_tree().paused = visible
	if not GameParameters.is_tutorial:
		queue_free()
		return
	_update_tutorial()


func _on_back_button_pressed():
	_current_index = clampi(_current_index - 1, 0, len(_tutorial) - 1)
	_update_tutorial()


func _on_next_button_pressed():
	if _current_index + 1 >= len(_tutorial):
		visible = false
		get_tree().paused = false
	else:
		_current_index = clampi(_current_index + 1, 0, len(_tutorial) - 1)
		_update_tutorial()


func _update_tutorial():
	%Text.text = _tutorial[_current_index].text
	%VideoStreamPlayer.stream = _tutorial[_current_index].video
	%VideoStreamPlayer.play()
	%BackButton.visible = _current_index > 0
	%NextButton.text = 'Next' if _current_index + 1 < len(_tutorial) else 'Close'
	%PageNumber.text = '{0} / {1}'.format([_current_index + 1, len(_tutorial)])
