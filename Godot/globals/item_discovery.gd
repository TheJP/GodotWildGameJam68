extends Node


signal discovery(data)


class Recipe:
	var input1: Item.Type
	var input2: Item.Type
	var output: Item.Type

	func _init(p_input1: Item.Type, p_input2: Item.Type, p_output: Item.Type):
		input1 = p_input1
		input2 = p_input2
		output = p_output


class Decay:
	var input: Item.Type
	var age: float
	var output: Item.Type

	func _init(p_input: Item.Type, p_age: float, p_output: Item.Type):
		input = p_input
		age = p_age
		output = p_output


var recipe_discovered := {}
var decay_discovered := {}


func set_recipe_discovered(input1: Item.Type, input2: Item.Type, output: Item.Type):
	if input1 in recipe_discovered:
		return
	recipe_discovered[input1] = {}
	if input2 not in recipe_discovered:
		recipe_discovered[input2] = {}
	if input2 in recipe_discovered[input1]:
		return

	recipe_discovered[input1][input2] = true
	recipe_discovered[input2][input1] = true
	await get_tree().process_frame
	discovery.emit(Recipe.new(input1, input2, output))


func set_decay_discovered(input: Item.Type, age: float, output: Item.Type):
	if input not in decay_discovered:
		decay_discovered[input] = true
		await get_tree().process_frame
		discovery.emit(Decay.new(input, age, output))
