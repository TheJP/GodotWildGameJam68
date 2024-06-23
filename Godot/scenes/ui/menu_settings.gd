extends Control


const MASTER_BUS: String = 'Master'
const SOUND_BUS: String = 'Sound'
const MUSIC_BUS: String = 'Music'


@onready var _master: HSlider = %MasterSlider
@onready var _sound: HSlider = %SoundSlider
@onready var _music: HSlider = %MusicSlider


var _was_paused_before := false
var _hovered = null


func _ready():
	_set_sliders()


func _on_visibility_changed():
	if visible:
		%Continue.grab_focus()
		_was_paused_before = get_tree().paused
		get_tree().paused = true
		if not _was_paused_before:
			AudioController.get_player('CalmMenuLoop').play()
	else:
		get_tree().paused = _was_paused_before
		if not _was_paused_before:
			AudioController.get_player('CalmMenuLoop').stop()
		_was_paused_before = false


func _unhandled_input(event):
	if event.is_action_pressed('ui_menu'):
		get_viewport().set_input_as_handled()
		visible = not visible
		_set_sliders()


func _set_sliders():
	_music.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS))))
	_sound.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(SOUND_BUS))))
	_master.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS))))


func _on_master_slider_value_changed(value):
	AudioController.get_player("MenuPressSound").play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS), linear_to_db(_master.value))


func _on_sound_slider_value_changed(value):
	AudioController.get_player("MenuPressSound").play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SOUND_BUS), linear_to_db(_sound.value))


func _on_music_slider_value_changed(value):
	AudioController.get_player("MenuPressSound").play()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), linear_to_db(_music.value))


func _on_continue_pressed():
	AudioController.get_player("MenuPressSound").play()
	hide()


func _on_back_to_menu_pressed():
	AudioController.get_player("MenuPressSound").play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/menu_main.tscn")


func _button_hovered(control: String):
	if _hovered != control:
		_hovered = control
		AudioController.get_player("MenuHoverSound").play()


func _button_unhovered():
	_hovered = null
