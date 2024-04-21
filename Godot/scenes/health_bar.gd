extends ProgressBar
@onready var _animation_player = $AnimationPlayer

func _ready():
	GlobalStats.update_health_bar.connect(on_update)
	max_value = GlobalStats.factory_health
	value = GlobalStats.factory_health

func on_update():
	_animation_player.play("taking_dmg")
	value = GlobalStats.factory_health
