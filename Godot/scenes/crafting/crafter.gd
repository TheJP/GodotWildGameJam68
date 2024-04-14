extends Node2D


func _on_hovered():
	scale = Vector2(1.1, 1.1)


func _on_unhovered():
	scale = Vector2(1, 1)


func _on_received_item():
	pass # Replace with function body.
