extends Control


const SOUND_BUS: String = 'Master'
const MUSIC_BUS: String = 'Music'


@onready var _sound: HSlider = %SoundSlider
@onready var _music: HSlider = %MusicSlider


func _ready():
	_set_sliders()


func _unhandled_input(event):
	if event.is_action_pressed('ui_menu'):
		visible = not visible
		get_tree().paused = visible
		_set_sliders()


func _set_sliders():
	_sound.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(SOUND_BUS)))
	_music.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS)))


func _on_sound_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SOUND_BUS), linear_to_db(_sound.value))


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), linear_to_db(_music.value))


func _on_continue_pressed():
	hide()
	get_tree().paused = false


func _on_back_to_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/menu_main.tscn")
