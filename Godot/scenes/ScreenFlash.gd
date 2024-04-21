extends ColorRect

func _ready():
	GlobalStats.update_health_bar.connect(on_update)

func on_update():
	var tween = create_tween()
	tween.tween_property(self, "color:a", 0.5, 0.25)
	await tween.finished
	tween = create_tween()
	tween.tween_property(self, "color:a", 0, 0.25)
	await tween.finished
