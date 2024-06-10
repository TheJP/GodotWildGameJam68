extends Control

@onready var sprite = %ItemSprite
@onready var label = %ItemName
@onready var description = %Description
@onready var recipe_input1 = %RecipeLeftItem
@onready var recipe_input2 = %RecipeRightItem
@onready var recipe_time = %RecipeTime

var discovery_queue = []
var effect
var _hovered = null


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


func _on_discovery(data):
	if not self.visible:
		var type: Item.Type = data.output
		sprite.texture = Item.sprites[type]
		if Item.effects[type] != null:
			effect = Item.effects[type].instantiate()
			sprite.add_child(effect)
			effect.global_position = sprite.global_position + sprite.size * 0.5
			effect.show_behind_parent = true

		label.text = '[center][shake rate=20 level=15]{0}'.format([Item.names[type]])
		description.text = Item.descriptions[type]

		# TODO: Add effects to recipe inputs
		if data is ItemDiscovery.Recipe:
			recipe_input1.texture = Item.sprites[data.input1]
			recipe_input2.texture = Item.sprites[data.input2]
			recipe_input2.visible = true
			recipe_time.visible = false
		elif data is ItemDiscovery.Decay:
			print(data.input)
			print(Item.sprites[data.input].load_path)
			recipe_input1.texture = Item.sprites[data.input] # TODO: Fire->Coal sprite not set correctly?
			recipe_time.text = '{0}s'.format([data.age])
			recipe_input2.visible = false
			recipe_time.visible = true

		self.visible = true
		AudioController.get_player("ItemDiscoveryLoop").play()
		AudioController.get_player("ItemDiscoverySound").play()
		get_tree().paused = true
	else:
		discovery_queue.append(data)


func _button_hovered(control: String):
	if _hovered != control:
		_hovered = control
		AudioController.get_player("MenuHoverSound").play()


func _button_unhovered():
	_hovered = null
