extends Node

var factory_health = 100
var progress = 0
var times_spawned = 1
var highscore = 0
signal update_health_bar

var reachedTransition = false


static var _loops: Array[String] = [
	'Level1Loop',
	'Level2Loop',
	'Level3Loop',
	'Level4Loop',
	'Transition',
	'EndgameLoop',
]
static var _loop_transition := {
	4: true,
}


func new_game():
	factory_health = 100
	progress = 0
	times_spawned = 1


func update_health(amount):
	factory_health += amount

	update_health_bar.emit()
	if factory_health <= 0:
		await get_tree().create_timer(1).timeout
		for loop in _loops:
			AudioController.get_player(loop).stop()
		AudioController.get_player("GameOverSound").play()
		get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
	else:
		AudioController.get_player("FactoryDamageSound").play()


func _process(_delta):
	if factory_health <= 0:
		return
	var target_player := AudioController.get_player(_loops[progress])
	if target_player.playing:
		return

	var all_done = true
	for i in _loops.size():
		if i == progress:
			continue
		var player := AudioController.get_player(_loops[i])
		player.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
		all_done = all_done and not player.playing

	if all_done:
		if progress not in _loop_transition:
			target_player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			target_player.play()
		else:
			target_player.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
			target_player.play()
			progress += 1


func set_progress_level(level):
	progress = level
