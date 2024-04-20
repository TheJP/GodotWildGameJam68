extends Node


signal discovery(type: Item.Type)


var discovered := {
	Item.Type.WOOD: true,
	Item.Type.STONE: true,
}


func set_discovered(type):
	if type not in discovered:
		discovered[type] = true
		await get_tree().process_frame
		discovery.emit(type)
