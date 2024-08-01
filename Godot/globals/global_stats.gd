extends Node


const HIGHSCORE_PATH := 'user://highscore.txt'


var factory_health
var progress
var times_spawned
var highscore = 0
signal update_health_bar
var _game_over_triggered := false


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


func _ready():
	on_new_game()
	_load_highscore()
	Game.new_game.connect(on_new_game)


func on_new_game():
	factory_health = 100
	progress = 0
	times_spawned = 1
	_game_over_triggered = false


func set_highscore(score):
	highscore = score
	var file := FileAccess.open(HIGHSCORE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_line(str(highscore))


func _load_highscore():
	highscore = 0
	var file := FileAccess.open(HIGHSCORE_PATH, FileAccess.READ)
	if file == null:
		return
	var highscore_text = file.get_as_text().strip_edges()
	if highscore_text.is_valid_int():
		highscore = highscore_text.to_int()


func update_health(amount):
	factory_health += amount

	update_health_bar.emit()
	if factory_health <= 0 and not _game_over_triggered:
		_game_over_triggered = true # Prevent game over from triggering multiple times.
		await get_tree().create_timer(1).timeout
		for loop in _loops:
			AudioController.get_player(loop).stop()
		AudioController.get_player("GameOverSound").play()
		get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
		Game.trigger_game_over()
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
