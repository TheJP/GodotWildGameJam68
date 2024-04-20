extends Node

signal discovery(type: Item.Type)

var discovered := {
	Item.Type.TRASH: false,
	Item.Type.WOOD: true,
	Item.Type.STONE: true,
	Item.Type.IRON_ORE: false,
	Item.Type.FIRE: false,
	Item.Type.HAMMER: false,
	Item.Type.TORCH: false,
	Item.Type.COAL: false,
	Item.Type.HOT_FIRE: false,
	Item.Type.HOT_STEEL: false,
	Item.Type.SPEAR: false,
	Item.Type.STEEL: false,
	Item.Type.SWORD: false,
	Item.Type.WOODEN_SHIELD: false,
	Item.Type.IRON_SHIELD: false,
	Item.Type.BATTLE_HAMMER: false,
	Item.Type.BOOMERANG: false,
}

func set_discovered(type):
	discovered[type] = true
	discovery.emit(type)
	
