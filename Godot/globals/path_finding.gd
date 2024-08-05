extends Node


var _roads := {}
signal layout_changed()


func _ready():
	Game.new_game.connect(_on_new_game)


func _on_new_game():
	_roads = {}


func register_road(road: Road):
	var index := Tile.index(road.global_position)
	if index in _roads and is_instance_valid(_roads[index]):
		road.queue_free()
		push_warning('duplicate road, keeping already existing road and deleting newly added at {0}'.format([index]))
		return
	_roads[index] = road
	layout_changed.emit()


func remove_road(road: Road):
	var index := Tile.index(road.global_position)
	if index not in _roads:
		return
	_roads.erase(index)
	layout_changed.emit()


func has_road(index: Vector2i) -> bool:
	return index in _roads


func get_road(index: Vector2i):
		return _roads.get(index)


func check_path_valid(path: Array[Vector2i]) -> bool:
	for index in path:
		if index not in _roads:
			return false
	return true


func find_path(from: Vector2i, target: Vector2i, target_size: Vector2i = Vector2i.ONE) -> Array[Vector2i]:
	# TODO: To improve performance: cache path finding results.
	if from not in _roads:
		return []

	const directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	var target_rect := Rect2i(target, target_size)
	if target_rect.has_point(from):
		return [from]

	var visited := { from: true }
	var bfs: Array[Vector2i] = [from]  # TODO: pop_front takes O(n) time, so a better queue data structure would be good.
	var parent := {}

	while not bfs.is_empty():
		var current: Vector2i = bfs.pop_front()
		for direction in directions:
			var next := current + direction
			if next not in visited:
				visited[next] = true
				parent[next] = current

				if target_rect.has_point(next):
					var path: Array[Vector2i] = [next]
					var walk := next
					while walk in parent:
						walk = parent[walk]
						path.append(walk)
					path.reverse()
					return path

				if next in _roads:
					bfs.push_back(next)

	return []
