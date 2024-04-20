extends Control

@onready var sprite = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Sprite
@onready var label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Label2
@onready var _animation_player = $AnimationPlayer

var discovery_queue = []

func _ready():
	ItemDiscovery.discovery.connect(_on_discovery)
	self.visible = false

func _on_button_pressed():
	self.visible = false
	get_tree().paused = false
	if !discovery_queue.is_empty():
		_on_discovery(discovery_queue.pop_front())

func _on_discovery(type):
	if(self.visible == false):
		sprite.texture = Item.sprites[type]
		label.text = Item.names[type]
		self.visible = true
		AudioController.get_player("ItemDiscoverySound").play()
		_animation_player.play("party_fireworks")
		get_tree().paused = true
	else:
		discovery_queue.append(type)
