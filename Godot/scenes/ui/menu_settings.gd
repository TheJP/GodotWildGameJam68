extends Control


func _input(event):
	if event is InputEventAction:
		print('event')
		if event.pressed and event.action == 'ui_menu':
			print('menu')
			show()
	#event.is_action('ui_menu')
