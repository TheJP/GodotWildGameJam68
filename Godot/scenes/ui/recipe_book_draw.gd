extends Control


var recipe_graph := {}
var recipe_parents := {}
var sorted_items = []  # topological sort


func _ready():
	_build_graph()
	_sort_topological()


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
		if item not in recipe_graph:
			continue
		for child in recipe_graph[item]:
			parents[child].erase(item)
			if parents[child].is_empty():
				next.append(child)

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
	draw_line(Vector2(0, 0), Vector2(size.x, size.y), Color.GREEN, 3.0, true)
