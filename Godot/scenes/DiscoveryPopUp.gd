extends Control

@onready var sprite = %ItemSprite
@onready var label = %ItemName
@onready var description = %Description

var discovery_queue = []
var effect

func _ready():
	ItemDiscovery.discovery.connect(_on_discovery)
	self.visible = false

func _on_button_pressed():
	self.visible = false
	if effect != null:
		effect.queue_free()
		effect = null
	get_tree().paused = false
	if !discovery_queue.is_empty():
		_on_discovery(discovery_queue.pop_front())
	else:
		AudioController.get_player("ItemDiscoveryLoop").stop()

func _on_discovery(type):
	if self.visible == false:
		sprite.texture = Item.sprites[type]
		if (Item.effects[type] != null):
			effect = Item.effects[type].instantiate()
			sprite.add_child(effect)
			effect.global_position = sprite.global_position + sprite.size * 0.5
			effect.show_behind_parent = true
		label.text = '[center][shake rate=20 level=15]{0}'.format([Item.names[type]])
		description.text = Item.descriptions[type]
		self.visible = true
		AudioController.get_player("ItemDiscoveryLoop").play()
		AudioController.get_player("ItemDiscoverySound").play()
		get_tree().paused = true
	else:
		discovery_queue.append(type)
