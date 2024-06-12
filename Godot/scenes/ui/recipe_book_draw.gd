extends Control


@onready var crafter_texture = preload('res://assets/crafter_plain.png')
@onready var font = preload('res://fonts/PixelifySans-VariableFont_wght.ttf')


var recipe_graph := {}
var recipe_parents := {}
var sorted_items = [] # topological sort
var item_levels := {} # determines the vertical order of items
var grid = []
var item_coordinates := {}


func _ready():
	_build_graph()
	_sort_topological()
	open() # FIXME: Remove line


func open():
	# TODO: Remove recipes/items that were not yet discovered
	grid = []
	item_coordinates = {}
	var level := 0
	while true:
		var row: Array[Item.Type] = []
		for item in item_levels.keys():
			if item_levels[item] == level:
				item_coordinates[item] = Vector2i(row.size(), grid.size())
				row.append(item)
		if row.is_empty():
			break
		grid.append(row)
		level += 1



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


var t := 0.0

func _process(delta):
	t += delta
	queue_redraw()


func _draw():
	var slot_width := size.x * (1.0 / 3.5)
	var item_size := Vector2.ONE * slot_width * 0.2
	var vertical_spacing := 20.0

	var y := 0
	var y_position := t * -50.0 # TODO: Add translation here
	var next_y_position := y_position
	for row in grid:
		var x := 0
		for item in row:
			var slot_position := Vector2(x * slot_width, y_position)
			var item_position := slot_position + \
				Vector2.DOWN * vertical_spacing + \
				Vector2.RIGHT * (0.5 * slot_width - 0.5 * item_size.x)
			draw_texture_rect(Item.sprites[item], Rect2(item_position, item_size), false)

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

				var ingredient_rect := Rect2(recipe_position, Vector2(0.5 * recipe_size.x, recipe_size.y))
				draw_texture_rect(Item.sprites[input], ingredient_rect, false)
				var label_size := 40
				ingredient_rect.position += 0.5 * recipe_size + Vector2.DOWN * label_size * 0.5
				draw_string(font, ingredient_rect.position, '+ {0}s'.format([decay.age]), HORIZONTAL_ALIGNMENT_LEFT, -1, label_size)

				recipe_position.y += recipe_size.y + vertical_spacing
			for recipe in Item.recipes: # TODO: Improve performance by precomputing this on open.
				if recipe.output.is_id or recipe.output.is_nothing or recipe.output.type != item:
					continue

				draw_texture_rect(crafter_texture, Rect2(recipe_position, recipe_size), false)
				var ingredient_rect := Rect2(recipe_position, Vector2(0.5 * recipe_size.x, recipe_size.y))
				draw_texture_rect(Item.sprites[recipe.input1], ingredient_rect, false)
				ingredient_rect.position.x += 0.5 * recipe_size.x
				draw_texture_rect(Item.sprites[recipe.input2], ingredient_rect, false)

				recipe_position.y += recipe_size.y + vertical_spacing

			next_y_position = max(next_y_position, recipe_position.y + vertical_spacing)
			x += 1
		y_position = next_y_position
		y += 1
