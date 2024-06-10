extends Control

@onready var sprite = %ItemSprite
@onready var label = %ItemName
@onready var description = %Description
@onready var recipe_input1 = %RecipeLeftItem
@onready var recipe_input2 = %RecipeRightItem
@onready var recipe_time = %RecipeTime

var discovery_queue = []
var effects = []
var _hovered = null


func _ready():
	ItemDiscovery.discovery.connect(_on_discovery)
	self.visible = false


func _on_button_pressed():
	self.visible = false
	for effect in effects:
		effect.queue_free()
	effects = []
	get_tree().paused = false
	if !discovery_queue.is_empty():
		_on_discovery(discovery_queue.pop_front())
	else:
		AudioController.get_player("ItemDiscoveryLoop").stop()


func _on_discovery(data):
	if not self.visible:
		var type: Item.Type = data.output
		_set_item_visual(sprite, type)
		label.text = '[center][shake rate=20 level=15]{0}'.format([Item.names[type]])
		description.text = Item.descriptions[type]

		# TODO: Add effects to recipe inputs
		if data is ItemDiscovery.Recipe:
			_set_item_visual(recipe_input1, data.input1)
			_set_item_visual(recipe_input2, data.input2)
			recipe_input2.visible = true
			recipe_time.visible = false
		elif data is ItemDiscovery.Decay:
			_set_item_visual(recipe_input1, data.input)
			recipe_time.text = '{0}s'.format([data.age])
			recipe_input2.visible = false
			recipe_time.visible = true

		self.visible = true
		AudioController.get_player("ItemDiscoveryLoop").play()
		AudioController.get_player("ItemDiscoverySound").play()
		get_tree().paused = true
	else:
		discovery_queue.append(data)


func _set_item_visual(target: TextureRect, type: Item.Type):
	target.texture = Item.sprites[type]
	target.tooltip_text = Item.names[type]
	if Item.effects[type] == null:
		return
	var effect = Item.effects[type].instantiate()
	target.add_child(effect)
	effect.global_position = target.global_position + target.size * 0.5
	effect.show_behind_parent = true
	effects.append(effect)


func _button_hovered(control: String):
	if _hovered != control:
		_hovered = control
		AudioController.get_player("MenuHoverSound").play()


func _button_unhovered():
	_hovered = null
