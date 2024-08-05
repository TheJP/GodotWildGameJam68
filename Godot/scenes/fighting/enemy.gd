extends Area2D


@onready var health_bar = $HealthBar
@onready var fire_animation = $FlameDamage


const sounds_death = ['EnemyDeathSound1', 'EnemyDeathSound2', 'EnemyDeathSound3']
const sounds_damage = ['DamageTickSound1', 'DamageTickSound2', 'DamageTickSound3']


var _path: Array[Vector2i] = []
var _path_index := 0
var _current_road = null
var _village_index: Vector2i
var _hovering = false

var health = 20
var damage = 1
var move_frequency = 2
var counter = 0
var is_plant = false
var animation_speed = 3
var village_damage = 10


func _ready():
	health_bar.max_value = health
	var index := Tile.index(global_position)
	_current_road = PathFinding.get_road(index)
	if not is_instance_valid(_current_road) or _current_road.fighter != self:
		push_warning('enemy did not spawn on road or road was already occupied')

	# TODO: Improve performance by not searching village with each enemy.
	PathFinding.layout_changed.connect(on_road_layout_changed)
	var village = get_tree().get_first_node_in_group('village')
	_village_index = Tile.index(village.global_position) - Vector2i.ONE
	_path = PathFinding.find_path(index, _village_index, Vector2i(3, 3)) # TODO: magic numbers
	_path_index = 1

	Game.timer.timeout.connect(_on_global_ticker_timeout)


func on_road_layout_changed():
	var index := Tile.index(global_position)
	_path = PathFinding.find_path(index, _village_index, Vector2i(3, 3)) # TODO: magic numbers
	_path_index = 1


func _on_global_ticker_timeout():
	counter += 1
	if counter < move_frequency:
		return
	counter = 0

	if _path_index < _path.size():
		var target_index := _path[_path_index]
		var target_position := Tile.position(target_index)
		if _path_index + 1 == _path.size():
			# Reached village -> deal damage.
			GlobalStats.update_health(-village_damage)
			if is_instance_valid(_current_road):
				_current_road.fighter = null

			var tween := create_tween()
			tween.set_parallel()
			tween.tween_property(self, 'global_position',
				target_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
			tween.tween_property(self, 'scale',
				0.5 * Vector2.ONE, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
			await tween.finished

			queue_free()
			return

		var target_road: Road = PathFinding.get_road(target_index)
		if target_road == null or is_instance_valid(target_road.fighter):
			return
		if is_instance_valid(_current_road):
			_current_road.fighter = null
		target_road.fighter = self
		_current_road = target_road

		create_tween().tween_property(self, 'global_position',
			target_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)

		_path_index += 1


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if not event.pressed or not _hovering:
			return
		if ClickCooldown.try_click_action():
			take_damage(1)
			get_viewport().set_input_as_handled()


func _on_mouse_entered():
	_hovering = true


func _on_mouse_exited():
	_hovering = false


func take_damage(amount, is_fire: bool = false):
	if is_fire and self.is_plant:
		amount += 200
	if health_bar.visible == false:
		health_bar.visible = true
	health -= amount
	health_bar.value = health

	if is_fire and self.is_plant and not AudioController.get_player("BurningDamageSound").playing:
		AudioController.get_player("BurningDamageSound").play()
	elif health <= 0:
		AudioController.get_player(sounds_death.pick_random()).play()
		self.queue_free()
	else:
		AudioController.get_player(sounds_damage.pick_random()).play()

	$Sprite2D.modulate = Color.RED
	if is_fire and self.is_plant:
		fire_animation.visible = true
	await get_tree().create_timer(0.1).timeout
	$Sprite2D.modulate = Color.WHITE
	await get_tree().create_timer(0.5).timeout
	fire_animation.visible = false