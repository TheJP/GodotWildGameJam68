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

	func _init(p_health: int, p_damage: int, p_destroy_on_pickup: bool = false, p_throwable: int = 0):
		health = p_health
		damage = p_damage
		destroy_on_pickup = p_destroy_on_pickup
		throwable = p_throwable

static var recipes: Array[Recipe] = [
	Recipe.new(Type.WOOD, Type.WOOD, Type.FIRE),
	Recipe.new(Type.WOOD, Type.STONE, Type.SPEAR),
	Recipe.new(Type.WOOD, Type.IRON_ORE, Type.HAMMER),
	Recipe.new(Type.WOOD, Type.FIRE, Type.TORCH),
	Recipe.new(Type.WOOD, Type.TORCH, Type.TORCH),
	Recipe.new(Type.WOOD, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.WOOD, Type.HOT_STEEL, Type.FIRE),
	Recipe.new(Type.WOOD, Type.HAMMER, Type.WOODEN_SHIELD),

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
