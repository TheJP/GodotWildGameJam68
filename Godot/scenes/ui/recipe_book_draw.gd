extends Control


@onready var crafter_texture = preload('res://assets/crafter_plain.png')
@onready var font = preload('res://fonts/PixelifySans-VariableFont_wght.ttf')


var recipe_graph := {}
var recipe_parents := {}
var sorted_items = [] # topological sort
var item_levels := {} # determines the vertical order of items
var grid = []
var item_coordinates := {}


var _recipe_translation := Vector2.ZERO
var _dragging := false
var _drag_start: Vector2
@onready var _is_debug: bool = get_tree().current_scene.name == 'RecipeBook'
var _effects_item := {}
var _effects_input := {}


func _ready():
	_build_graph()
	_sort_topological()
	if _is_debug:
		open()


func _add_effect(type: Item.Type) -> Node2D:
	if Item.effects[type] == null:
		push_error('_add_effect(type) calles with invalid type')
	var effect = Item.effects[type].instantiate()
	add_child(effect)
	effect.show_behind_parent = true
	effect.scale = 1.5 * Vector2.ONE # TODO: Compute this instead of a hardcoded value.
	return effect


func open():
	grid = []
	item_coordinates = {}
	var items = item_levels.keys() if _is_debug else ItemDiscovery.item_discovered.keys()
	for level in range(item_levels.values().max() + 1):
		var row: Array[Item.Type] = []
		for item in items:
			if item_levels[item] == level:
				item_coordinates[item] = Vector2i(row.size(), grid.size())
				row.append(item)
		grid.append(row)

	for item in items:
		if Item.effects[item] == null:
			continue
		var effect := _add_effect(item)
		_effects_item[item] = effect


func _build_graph():
	for recipe in Item.recipes:
		if recipe.ignore_in_book or recipe.output.is_id or recipe.output.is_nothing:
			continue
		if recipe.input1 == recipe.output.type or recipe.input2 == recipe.output.type:
			continue # skip cyclic recipes
		_add_edge(recipe.input1, recipe.output.type)
		_add_edge(recipe.input2, recipe.output.type)
	for input: Item.Type in Item.decay.keys():
		var output: Item.Output = Item.decay[input].output
		if output.is_id or output.is_nothing:
			continue
		if input == output.type:
			continue
		_add_edge(input, output.type)

	for item in recipe_graph.keys():
		if item not in recipe_parents:
			recipe_parents[item] = []


func _sort_topological():
	var parents := recipe_parents.duplicate(true)
	var next: Array[Item.Type] = []
	for child in parents.keys():
		if parents[child].is_empty():
			next.append(child)

	while not next.is_empty():
		var item: Item.Type = next.pop_back()
		sorted_items.append(item)

		var parent_level := -1
		for parent in recipe_parents[item]:
			parent_level = max(parent_level, item_levels[parent])
		item_levels[item] = parent_level + 1

		if item not in recipe_graph:
			continue
		for child in recipe_graph[item]:
			parents[child].erase(item)
			if parents[child].is_empty():
				next.append(child)

	# If this assertion fails, you might have added recipes that cause a cycle.
	# Use the ignore_in_book parameter of the Recipe to remove recipes that cause a cycle.
	assert(sorted_items.size() == recipe_parents.size(), 'could not build recipe tree: found cycle')


func _add_edge(from: Item.Type, to: Item.Type):
	if from not in recipe_graph:
		recipe_graph[from] = []
	if to not in recipe_parents:
		recipe_parents[to] = []
	if to not in recipe_graph[from]:
		recipe_graph[from].append(to)
	if from not in recipe_parents[to]:
		recipe_parents[to].append(from)


func _gui_input(event):
	if event is InputEventMouseButton:
		if _dragging and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			accept_event()
			_dragging = false
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			accept_event()
			_dragging = true
			_drag_start = event.position - _recipe_translation
		if not _dragging and event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
			accept_event()
			_recipe_translation = Vector2.ZERO
			queue_redraw()
	elif event is InputEventMouseMotion:
		if _dragging:
			_recipe_translation = event.position - _drag_start
			queue_redraw()


func _draw():
	var slot_width := size.x * (1.0 / 3.5)
	var item_size := Vector2.ONE * slot_width * 0.2
	var vertical_spacing := 20.0

	var y := 0
	var root_position := _recipe_translation
	var next_root_position := root_position
	for row in grid:
		var x := 0
		for item in row:
			var slot_position := root_position + Vector2(x * slot_width, 0)
			var item_position := slot_position + \
				Vector2.DOWN * vertical_spacing + \
				Vector2.RIGHT * (0.5 * slot_width - 0.5 * item_size.x)
			draw_texture_rect(Item.sprites[item], Rect2(item_position, item_size), false)
			if item in _effects_item:
				_effects_item[item].global_position = global_position + item_position + 0.5 * item_size

			var name_position := Vector2(slot_position.x, item_position.y + item_size.y + 2.0 * vertical_spacing)
			var name_size := 35
			draw_string(font, name_position, Item.names[item], HORIZONTAL_ALIGNMENT_CENTER, slot_width, name_size)

			var recipe_size := Vector2(item_size.x * 2.0, item_size.y)
			var recipe_position := Vector2(
				slot_position.x + 0.5 * slot_width - 0.5 * recipe_size.x,
				name_position.y + 2.0 * vertical_spacing)

			for input in Item.decay.keys():
				var decay: Item.Decay = Item.decay[input]
				if decay.output.is_id or decay.output.is_nothing or decay.output.type != item:
					continue
				if not _is_debug and input not in ItemDiscovery.decay_discovered:
					continue

				var ingredient_rect := Rect2(recipe_position, Vector2(0.5 * recipe_size.x, recipe_size.y))
				draw_texture_rect(Item.sprites[input], ingredient_rect, false)
				var label_size := 40
				ingredient_rect.position += 0.5 * recipe_size + Vector2.DOWN * label_size * 0.5
				draw_string(font, ingredient_rect.position, '+ {0}s'.format([decay.age]), HORIZONTAL_ALIGNMENT_LEFT, -1, label_size)

				recipe_position.y += recipe_size.y + vertical_spacing
			for recipe in Item.recipes: # TODO: Improve performance by precomputing this on open.
				if recipe.output.is_id or recipe.output.is_nothing or recipe.output.type != item:
					continue
				if not _is_debug and \
						(recipe.input1 not in ItemDiscovery.recipe_discovered or \
						recipe.input2 not in ItemDiscovery.recipe_discovered[recipe.input1]):
					continue

				draw_texture_rect(crafter_texture, Rect2(recipe_position, recipe_size), false)
				var ingredient_rect := Rect2(recipe_position, Vector2(0.5 * recipe_size.x, recipe_size.y))
				draw_texture_rect(Item.sprites[recipe.input1], ingredient_rect, false)
				ingredient_rect.position.x += 0.5 * recipe_size.x
				draw_texture_rect(Item.sprites[recipe.input2], ingredient_rect, false)

				recipe_position.y += recipe_size.y + vertical_spacing

			next_root_position = Vector2(root_position.x, max(next_root_position.y, recipe_position.y + vertical_spacing))
			x += 1
		root_position = next_root_position
		y += 1
