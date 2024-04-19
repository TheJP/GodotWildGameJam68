extends ProgressBar

func _ready():
	GlobalStats.update_health_bar.connect(on_update)
	max_value = GlobalStats.factory_health
	value = GlobalStats.factory_health
	
func on_update():
	value = GlobalStats.factory_health
