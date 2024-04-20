class_name Item


enum Type {
	TRASH,
	WOOD,
	STONE,
	IRON_ORE,
	FIRE,
	HAMMER,
	TORCH,
	COAL,
	HOT_FIRE,
	HOT_STEEL,
	SPEAR,
	STEEL,
	SWORD,
	WOODEN_SHIELD,
	IRON_SHIELD,
	BATTLE_HAMMER,
	BOOMERANG,
	SUPER_SWORD,
	ULTRA_SWORD,
	SUPER_ULTRA_SWORD,
	SUPER_BOOMERANG,
	ULTRA_BOOMERANG,
	SUPER_ULTRA_BOOMERANG,
	SUPER_SHIELD,
	ULTRA_SHIELD,
	SUPER_ULTRA_SHIELD,
	SUPER_BATTLE_HAMMER,
	ULTRA_BATTLE_HAMMER,
	SUPER_ULTRA_BATTLE_HAMMER,
}


class Recipe:
	var input1: Type
	var input2: Type
	var output: Output

	func _init(p_input1: Type, p_input2: Type, p_output):
		input1 = p_input1
		input2 = p_input2
		output = Output.new(p_output)


class Decay:
	var age: float
	var output: Output

	func _init(p_age: float, p_output):
		age = p_age
		output = Output.new(p_output)


class Output:
	var type: Type
	var is_id: bool
	var is_nothing: bool

	func _init(p_type):
		is_id = p_type is Id
		is_nothing = p_type is Nothing
		if p_type is Type:
			type = p_type


class Id:
	pass


class Nothing:
	pass

class StatModifier:
	var health: int
	var damage: int
	var destroy_on_pickup: bool
	var throwable: int #0 if not throwable, otherwise signifies throw damage amount
	var ranged: bool
	var level: int

	func _init(p_health: int,
	 p_damage: int,
	 p_destroy_on_pickup: bool = false,
	 p_throwable: int = 0,
	 p_ranged: bool = false,
	 p_level: int = 0,
	):
		health = p_health
		damage = p_damage
		destroy_on_pickup = p_destroy_on_pickup
		throwable = p_throwable
		ranged = p_ranged
		level = p_level

static var recipes: Array[Recipe] = [
	Recipe.new(Type.WOOD, Type.WOOD, Type.FIRE),
	Recipe.new(Type.WOOD, Type.STONE, Type.SPEAR),
	Recipe.new(Type.WOOD, Type.IRON_ORE, Type.HAMMER),
	Recipe.new(Type.WOOD, Type.FIRE, Type.TORCH),
	Recipe.new(Type.WOOD, Type.TORCH, Type.TORCH),
	Recipe.new(Type.WOOD, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.WOOD, Type.HOT_STEEL, Type.FIRE),
	Recipe.new(Type.WOOD, Type.HAMMER, Type.WOODEN_SHIELD),
	Recipe.new(Type.WOOD, Type.STEEL, Type.BATTLE_HAMMER),
	
	Recipe.new(Type.STONE, Type.STONE, Type.IRON_ORE),
	Recipe.new(Type.STONE, Type.FIRE, Type.STONE),

	Recipe.new(Type.IRON_ORE, Type.IRON_ORE, Type.TORCH),
	Recipe.new(Type.IRON_ORE, Type.FIRE, Type.IRON_ORE),
	Recipe.new(Type.IRON_ORE, Type.HOT_FIRE, Type.HOT_STEEL),
	Recipe.new(Type.IRON_ORE, Type.HAMMER, Type.IRON_SHIELD),

	Recipe.new(Type.FIRE, Type.FIRE, Nothing.new()),
	Recipe.new(Type.FIRE, Type.TORCH, Nothing.new()),
	Recipe.new(Type.FIRE, Type.COAL, Type.HOT_FIRE),
	Recipe.new(Type.FIRE, Type.HOT_FIRE, Nothing.new()),
	Recipe.new(Type.FIRE, Type.STEEL, Type.STEEL),
	Recipe.new(Type.FIRE, Type.HOT_STEEL, Type.HOT_STEEL),

	Recipe.new(Type.HAMMER, Type.HOT_STEEL, Type.SWORD),
	Recipe.new(Type.HAMMER, Type.STEEL, Type.BOOMERANG),

	Recipe.new(Type.TORCH, Type.HOT_FIRE, Nothing.new()),
	Recipe.new(Type.TORCH, Type.COAL, Type.HOT_FIRE),

	Recipe.new(Type.COAL, Type.COAL, Type.COAL),
	Recipe.new(Type.COAL, Type.HOT_FIRE, Type.HOT_FIRE),

	Recipe.new(Type.HOT_FIRE, Type.HOT_FIRE, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.HOT_FIRE, Type.HOT_STEEL, Type.HOT_STEEL),

	Recipe.new(Type.HOT_STEEL, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.HOT_STEEL, Type.STEEL, Type.STEEL),

	Recipe.new(Type.STEEL, Type.STEEL, Type.STEEL),
	
	Recipe.new(Type.SWORD, Type.SWORD, Type.SUPER_SWORD),
	Recipe.new(Type.SUPER_SWORD, Type.SUPER_SWORD, Type.ULTRA_SWORD),
	Recipe.new(Type.ULTRA_SWORD, Type.ULTRA_SWORD, Type.SUPER_ULTRA_SWORD),
	
	Recipe.new(Type.BOOMERANG, Type.BOOMERANG, Type.SUPER_BOOMERANG),
	Recipe.new(Type.SUPER_BOOMERANG, Type.SUPER_BOOMERANG, Type.ULTRA_BOOMERANG),
	Recipe.new(Type.ULTRA_BOOMERANG, Type.ULTRA_BOOMERANG, Type.SUPER_ULTRA_BOOMERANG),
	
	Recipe.new(Type.IRON_SHIELD, Type.IRON_SHIELD, Type.SUPER_SHIELD),
	Recipe.new(Type.SUPER_SHIELD, Type.SUPER_SHIELD, Type.ULTRA_SHIELD),
	Recipe.new(Type.ULTRA_SHIELD, Type.ULTRA_SHIELD, Type.SUPER_ULTRA_SHIELD),
	
	Recipe.new(Type.BATTLE_HAMMER, Type.BATTLE_HAMMER, Type.SUPER_BATTLE_HAMMER),
	Recipe.new(Type.SUPER_BATTLE_HAMMER, Type.SUPER_BATTLE_HAMMER, Type.ULTRA_BATTLE_HAMMER),
	Recipe.new(Type.ULTRA_BATTLE_HAMMER, Type.ULTRA_BATTLE_HAMMER, Type.SUPER_ULTRA_BATTLE_HAMMER),
]


static var decay := {
	Type.FIRE: Decay.new(10.0, Type.COAL),
	Type.TORCH: Decay.new(20.0, Type.COAL),
	Type.HOT_FIRE: Decay.new(10.0, Nothing.new()),
	Type.HOT_STEEL: Decay.new(20.0, Type.STEEL),
}


static var stat_modifiers := {
	Type.TRASH: StatModifier.new(0, -1),
	Type.WOOD: StatModifier.new(1, 0),
	Type.STONE: StatModifier.new(0, 0, false, 1),
	Type.IRON_ORE: StatModifier.new(0, 0, false, 1),
	Type.FIRE: StatModifier.new(-1, 0, true),
	Type.HAMMER: StatModifier.new(0, 1),
	Type.TORCH: StatModifier.new(0, 1),
	Type.COAL: StatModifier.new(0, 0, false, 1),
	Type.HOT_FIRE: StatModifier.new(-3, 0, true),
	Type.HOT_STEEL: StatModifier.new(-2, 0),
	Type.SPEAR: StatModifier.new(0, 2),
	Type.STEEL: StatModifier.new(0, 0, false, 2),
	Type.SWORD: StatModifier.new(0, 4),
	Type.WOODEN_SHIELD: StatModifier.new(2, 0),
	Type.IRON_SHIELD: StatModifier.new(3, 0),
	Type.BATTLE_HAMMER: StatModifier.new(1, 2),
	Type.BOOMERANG: StatModifier.new(0, 0, false, 2, true),
	Type.SUPER_SWORD: StatModifier.new(0, 8, false, 0, false, 1),
	Type.ULTRA_SWORD: StatModifier.new(0, 16, false, 0, false, 2),
	Type.SUPER_ULTRA_SWORD: StatModifier.new(0, 32, false, 0, false, 3),
	Type.SUPER_BOOMERANG: StatModifier.new(0, 0, false, 4, true, 1),
	Type.ULTRA_BOOMERANG: StatModifier.new(0, 0, false, 8, true, 2),
	Type.SUPER_ULTRA_BOOMERANG: StatModifier.new(0, 0, false, 16, true, 3),
	Type.SUPER_SHIELD: StatModifier.new(5, 0, false, 0, false, 1),
	Type.ULTRA_SHIELD: StatModifier.new(8, 0, false, 0, false, 2),
	Type.SUPER_ULTRA_SHIELD: StatModifier.new(16, 0, false, 0, false, 3),
	Type.SUPER_BATTLE_HAMMER: StatModifier.new(2, 4, false, 0, false, 1),
	Type.ULTRA_BATTLE_HAMMER: StatModifier.new(6, 6, false, 0, false, 2),
	Type.SUPER_ULTRA_BATTLE_HAMMER: StatModifier.new(10, 10, false, 0, false, 3),
}

static var names := {
	Type.TRASH: "Trash",
	Type.WOOD: "Wood",
	Type.STONE: "Stone",
	Type.IRON_ORE: "Iron Ore",
	Type.FIRE: "Fire",
	Type.HAMMER: "Hammer",
	Type.TORCH: "Torch",
	Type.COAL: "Coal",
	Type.HOT_FIRE: "Hot Fire",
	Type.HOT_STEEL: "Hot Steel",
	Type.SPEAR: "Spear",
	Type.STEEL: "Steel",
	Type.SWORD: "Sword",
	Type.WOODEN_SHIELD: "Wooden Shield",
	Type.IRON_SHIELD: "Iron Shield",
	Type.BATTLE_HAMMER: "Battle Hammer",
	Type.BOOMERANG: "Boomerang",
	Type.SUPER_SWORD: "Super Sword",
	Type.ULTRA_SWORD: "Ultra Sword",
	Type.SUPER_ULTRA_SWORD: "Super Ultra Sword of Ultimate Death",
	Type.SUPER_BOOMERANG: "Super Boomerang",
	Type.ULTRA_BOOMERANG: "Ultra Boomerang",
	Type.SUPER_ULTRA_BOOMERANG: "Super Ultra Boomerang of Ultimate Destruction",
	Type.SUPER_SHIELD: "Super Shield",
	Type.ULTRA_SHIELD: "Ultra Shield",
	Type.SUPER_ULTRA_SHIELD: "Super Ultra Shield of Ultimate Immortality",
	Type.SUPER_BATTLE_HAMMER: "Super Battle Hammer",
	Type.ULTRA_BATTLE_HAMMER: "Ultra Battle Hammer",
	Type.SUPER_ULTRA_BATTLE_HAMMER: "Super Ultra Battle Hammer of Ultimate Smashing",	
}

static var sprites := {
	Type.TRASH: preload('res://assets/items/trash.png'),
	Type.WOOD: preload('res://assets/items/wood.png'),
	Type.STONE: preload('res://assets/items/stone.png'),
	Type.IRON_ORE: preload('res://assets/items/iron_ore.png'),
	Type.FIRE: preload('res://assets/items/fire.png'),
	Type.HAMMER: preload('res://assets/items/hammer.png'),
	Type.TORCH: preload('res://assets/items/torch.png'),
	Type.COAL: preload('res://assets/items/coal.png'),
	Type.HOT_FIRE: preload('res://assets/items/hot_fire.png'),
	Type.HOT_STEEL: preload('res://assets/items/hot_steel.png'),
	Type.SPEAR: preload('res://assets/items/Spear.png'),
	Type.STEEL: preload('res://assets/items/steel.png'),
	Type.SWORD: preload('res://assets/items/sword.png'),
	Type.WOODEN_SHIELD: preload("res://assets/items/shield_wood.png"),
	Type.IRON_SHIELD: preload("res://assets/items/shield_iron.png"),
	Type.BATTLE_HAMMER: preload("res://assets/items/hammer_battle.png"),
	Type.BOOMERANG: preload("res://assets/items/boomerang.png"),
	Type.SUPER_SWORD: preload('res://assets/items/sword.png'),
	Type.ULTRA_SWORD: preload('res://assets/items/sword.png'),
	Type.SUPER_ULTRA_SWORD: preload('res://assets/items/sword.png'),
	Type.SUPER_BOOMERANG: preload("res://assets/items/boomerang.png"),
	Type.ULTRA_BOOMERANG: preload("res://assets/items/boomerang.png"),
	Type.SUPER_ULTRA_BOOMERANG: preload("res://assets/items/boomerang.png"),
	Type.SUPER_SHIELD: preload("res://assets/items/shield_iron.png"),
	Type.ULTRA_SHIELD: preload("res://assets/items/shield_iron.png"),
	Type.SUPER_ULTRA_SHIELD: preload("res://assets/items/shield_iron.png"),
	Type.SUPER_BATTLE_HAMMER: preload("res://assets/items/hammer_battle.png"),
	Type.ULTRA_BATTLE_HAMMER: preload("res://assets/items/hammer_battle.png"),
	Type.SUPER_ULTRA_BATTLE_HAMMER: preload("res://assets/items/hammer_battle.png"),	
	}

static var effects := {
	Type.TRASH: null,
	Type.WOOD: null,
	Type.STONE: null,
	Type.IRON_ORE: null,
	Type.FIRE: preload("res://effects/flame_particles.tscn"),
	Type.HAMMER: null,
	Type.TORCH: null,
	Type.COAL: null,
	Type.HOT_FIRE: preload("res://effects/hot_fire_particles.tscn"),
	Type.HOT_STEEL: null,
	Type.SPEAR: null,
	Type.STEEL: null,
	Type.SWORD: null,
	Type.WOODEN_SHIELD: null,
	Type.IRON_SHIELD: null,
	Type.BATTLE_HAMMER: null,
	Type.BOOMERANG: null,
	Type.SUPER_SWORD: preload("res://effects/sword_particles_blue.tscn"),
	Type.ULTRA_SWORD: preload("res://effects/sword_particles_purple.tscn"),
	Type.SUPER_ULTRA_SWORD: preload("res://effects/sword_particles_orange.tscn"),
	Type.SUPER_BOOMERANG: preload("res://effects/boomerang_particles_blue.tscn"),
	Type.ULTRA_BOOMERANG: preload("res://effects/boomerang_particles_purple.tscn"),
	Type.SUPER_ULTRA_BOOMERANG: preload("res://effects/boomerang_particles_orange.tscn"),
	Type.SUPER_SHIELD: preload("res://effects/shield_particles_blue.tscn"),
	Type.ULTRA_SHIELD: preload("res://effects/shield_particles_purple.tscn"),
	Type.SUPER_ULTRA_SHIELD: preload("res://effects/shield_particles_orange.tscn"),
	Type.SUPER_BATTLE_HAMMER: preload("res://effects/hammer_battle_particles_blue.tscn"),
	Type.ULTRA_BATTLE_HAMMER: preload("res://effects/hammer_battle_particles_purple.tscn"),
	Type.SUPER_ULTRA_BATTLE_HAMMER: preload("res://effects/hammer_battle_particles_orange.tscn"),	
}

static var crafting: Dictionary = _init_crafting(recipes)


static func _init_crafting(r: Array[Recipe]) -> Dictionary:
	var result = {}
	for recipe in r:
		if recipe.input1 not in result:
			result[recipe.input1] = {}
		if recipe.input2 not in result:
			result[recipe.input2] = {}
		result[recipe.input1][recipe.input2] = recipe.output
		if recipe.input1 != recipe.input2:
			result[recipe.input2][recipe.input1] = recipe.output

	return result
