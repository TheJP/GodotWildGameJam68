extends MarginContainer


func _ready():
	%DefaultButton.pivot_offset = %DefaultButton.size * 0.5
	%CrafterButton.pivot_offset = %CrafterButton.size * 0.5
	%PipeButton.pivot_offset = %PipeButton.size * 0.5
	%TrashButton.pivot_offset = %TrashButton.size * 0.5
	%DeleteButton.pivot_offset = %DeleteButton.size * 0.5


func _on_default_button_mouse_entered():
	%DefaultButton.scale = Vector2(1.2, 1.2)


func _on_default_button_mouse_exited():
	%DefaultButton.scale = Vector2(1, 1)


func _on_crafter_button_mouse_entered():
	%CrafterButton.scale = Vector2(1.2, 1.2)


func _on_crafter_button_mouse_exited():
	%CrafterButton.scale = Vector2(1, 1)


func _on_pipe_button_mouse_entered():
	%PipeButton.scale = Vector2(1.2, 1.2)


func _on_pipe_button_mouse_exited():
	%PipeButton.scale = Vector2(1, 1)


func _on_trash_button_mouse_entered():
	%TrashButton.scale = Vector2(1.2, 1.2)


func _on_trash_button_mouse_exited():
	%TrashButton.scale = Vector2(1, 1)


func _on_delete_button_mouse_entered():
	%DeleteButton.scale = Vector2(1.2, 1.2)


func _on_delete_button_mouse_exited():
	%DeleteButton.scale = Vector2(1, 1)
