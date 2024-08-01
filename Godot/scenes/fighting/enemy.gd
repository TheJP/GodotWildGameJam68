extends Area2D


var _path: Array[Vector2i] = []
var _path_index := 0
var _current_road = null


func _ready():
	var index := Tile.index(global_position)
	_current_road = PathFinding.get_road(index)
	if not is_instance_valid(_current_road) or _current_road.fighter != self:
		push_warning('enemy did not spawn on road or road was already occupied')

	# TODO: Improve performance by not searching village with each enemy.
	var village = get_tree().get_first_node_in_group('village')
	var village_index = Tile.index(village.global_position) - Vector2i.ONE
	_path = PathFinding.find_path(index, village_index, Vector2i(3, 3)) # TODO: magic numbers

	Game.timer.timeout.connect(_on_global_ticker_timeout)


func _on_global_ticker_timeout():
	if _path_index < _path.size():
		global_position = Tile.position(_path[_path_index])
		_path_index += 1
