extends Control


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


func _draw():
	var horizontal_spacing := size.x * (1.0 / 3.5)
	var y := 0
	for row in grid:
		var x := 0
		for item in row:
			draw_texture_rect(Item.sprites[item], Rect2(Vector2(x + 0.25, y) * horizontal_spacing, Vector2.ONE * horizontal_spacing * 0.5), false)
			x += 1
		y += 1


func _print_levels():
	var level = 0
	var found := true
	while found:
		found = false
		print('Level ' + str(level))
		for item: Item.Type in item_levels.keys():
			if item_levels[item] == level:
				print('    {0}'.format([Item.names[item]]))
				found = true
		level += 1
