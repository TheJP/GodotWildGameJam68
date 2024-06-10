extends Control


func _on_close_pressed():
	visible = false


func open():
	%Recipes.open()
	visible = true
