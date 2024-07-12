extends Control


var _was_paused_before := false


func _unhandled_input(event):
	if event.is_action_pressed('ui_recipe_book') and not visible:
		get_viewport().set_input_as_handled()
		open()


func _on_close_pressed():
	visible = false
	get_tree().paused = _was_paused_before
	if not _was_paused_before:
		AudioController.get_player('CalmMenuLoop').stop()
	%Recipes.close()


func open():
	%Recipes.open()
	%CloseButton.grab_focus()
	_was_paused_before = get_tree().paused
	get_tree().paused = true
	if not _was_paused_before:
		AudioController.get_player('CalmMenuLoop').play()
	visible = true
