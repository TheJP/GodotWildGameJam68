class_name Item


enum Type {
	TRASH,
	WOOD,
	STONE,
	STICKS,
	BASKET,
	BUCKET,
	WATER_BUCKET,
	STONE_AXE,
	STONE_PICKAXE,
	TORCH,
	COAL,
	FIRE,
	HOT_FIRE,
	SAND,
	MARACA,
	SANDSTONE,
	GLASS,
	POTION_BASE,
	HOURGLASS,
	IRON_ORE,
	HAMMER,
	SHOVEL,
	HOT_STEEL,
	STEEL,
	STEEL_AXE,
	STEEL_PICKAXE,
	BLADE,
	ARROW,
	SPEAR,
	STEEL_BOOMERANG,
	SHURRIKEN,
	WOODEN_SHIELD,
	IRON_SHIELD,
	SWORD,
	CHAIN,
	SICKLE,
	FIBER,
	FISHING_ROD,
	BOW,
	STONE_SLING,
	NET,
	MORNING_STAR,
	CHAIN_BLADE,
	CHAINMAIL,
	LEATHER,
	BATTLE_BANNER,
	LEATHER_SHIELD,
	LEATHER_SHIRT,
	WHIP,
	EMPTY_QUIVER,
	QUIVER,
	DIAMOND,
	RUNESTONE,
	WAND,
	STAFF,
	BERRIES,
	HERBS
}


class Recipe:
	var input1: Type
	var input2: Type
	var output: Output

	# Determines if this edge is drawn in the recipe book.
	# This has to be used to ignore all but one path in case of a cycle.
	var ignore_in_book: bool

	func _init(p_input1: Type, p_input2: Type, p_output, p_ignore_in_book := false):
		input1 = p_input1
		input2 = p_input2
		output = Output.new(p_output)
		ignore_in_book = p_ignore_in_book


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
	var is_fire: bool

	func _init(p_health: int,
	 p_damage: int,
	 p_destroy_on_pickup: bool = false,
	 p_throwable: int = 0,
	 p_ranged: bool = false,
	 p_level: int = 0,
	 p_is_fire: bool = false,
	):
		health = p_health
		damage = p_damage
		destroy_on_pickup = p_destroy_on_pickup
		throwable = p_throwable
		ranged = p_ranged
		level = p_level
		is_fire = p_is_fire


static var recipes: Array[Recipe] = [
	Recipe.new(Type.STICKS, Type.STICKS, Type.BASKET),
	
	# Wood Recipes
	Recipe.new(Type.WOOD, Type.STICKS, Type.FIRE),
	Recipe.new(Type.WOOD, Type.WOOD, Type.BUCKET),
	
	# Stone Recipes
	Recipe.new(Type.STICKS, Type.STONE, Type.STONE_AXE),
	Recipe.new(Type.WOOD, Type.STONE, Type.STONE_PICKAXE),
	Recipe.new(Type.STONE, Type.STONE, Type.STONE),
	
	# Basket Recipes
	#Recipe.new(Type.STICKS, Type.BASKET, Type.BASKET_OF_STICKS),
	#Recipe.new(Type.WOOD, Type.BASKET, Type.BASKET_OF_WOOD),
	#Recipe.new(Type.STONE, Type.BASKET, Type.BASKET_OF_STONES),
	
	# Bucket Recipes
	#Recipe.new(Type.STICKS, Type.BUCKET, Type.BUCKET_OF_STICKS),
	#Recipe.new(Type.WOOD, Type.BUCKET, Type.BUCKET_OF_WOOD),
	#Recipe.new(Type.STONE, Type.BUCKET, Type.BUCKET_OF_STONES),
	
	# Fire Recipes
	Recipe.new(Type.STICKS, Type.FIRE, Type.TORCH),
	Recipe.new(Type.WOOD, Type.FIRE, Type.FIRE),
	Recipe.new(Type.STONE, Type.FIRE, Type.STONE),
	Recipe.new(Type.BASKET, Type.FIRE, Type.FIRE),
	Recipe.new(Type.BUCKET, Type.FIRE, Type.FIRE),
	Recipe.new(Type.WATER_BUCKET, Type.FIRE, Type.BUCKET),
	Recipe.new(Type.FIRE, Type.FIRE, Type.FIRE),
	
	# Coal Recipes
	Recipe.new(Type.STICKS, Type.COAL, Type.FIRE),
	Recipe.new(Type.WOOD, Type.COAL, Type.FIRE),
	Recipe.new(Type.STONE, Type.COAL, Nothing.new()),
	Recipe.new(Type.BASKET, Type.COAL, Type.FIRE),
	Recipe.new(Type.BUCKET, Type.COAL, Type.FIRE),
	Recipe.new(Type.WATER_BUCKET, Type.COAL, Nothing.new()),
	Recipe.new(Type.FIRE, Type.COAL, Type.HOT_FIRE),
	Recipe.new(Type.COAL, Type.COAL, Type.COAL),
	
	# Hot Fire
	Recipe.new(Type.STICKS, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.WOOD, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.STONE, Type.HOT_FIRE, Nothing.new()),
	Recipe.new(Type.BASKET, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.BUCKET, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.WATER_BUCKET, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.FIRE, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.COAL, Type.HOT_FIRE, Type.HOT_FIRE),
	Recipe.new(Type.HOT_FIRE, Type.HOT_FIRE, Type.HOT_FIRE),
	
	# Sand
	Recipe.new(Type.STICKS, Type.SAND, Nothing.new()),
	Recipe.new(Type.WOOD, Type.SAND, Type.MARACA),
	Recipe.new(Type.STONE, Type.SAND, Type.SANDSTONE),
	#Recipe.new(Type.BASKET, Type.SAND, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.SAND, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.SAND, Nothing.new()),
	Recipe.new(Type.FIRE, Type.SAND, Type.GLASS),
	Recipe.new(Type.COAL, Type.SAND, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.SAND, Type.GLASS),
	Recipe.new(Type.SAND, Type.SAND, Type.SAND),
	
	# Glass
	Recipe.new(Type.STICKS, Type.GLASS, Nothing.new()),
	Recipe.new(Type.WOOD, Type.GLASS, Nothing.new()),
	Recipe.new(Type.STONE, Type.GLASS, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.GLASS, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.GLASS, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.GLASS, Type.POTION_BASE),
	Recipe.new(Type.FIRE, Type.GLASS, Type.GLASS),
	Recipe.new(Type.COAL, Type.GLASS, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.GLASS, Type.GLASS),
	Recipe.new(Type.SAND, Type.GLASS, Type.HOURGLASS),
	Recipe.new(Type.GLASS, Type.GLASS, Type.GLASS),
	
	# Iron Ore
	Recipe.new(Type.STICKS, Type.IRON_ORE, Type.HAMMER),
	Recipe.new(Type.WOOD, Type.IRON_ORE, Type.SHOVEL),
	Recipe.new(Type.STONE, Type.IRON_ORE, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.IRON_ORE, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.IRON_ORE, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.IRON_ORE, Nothing.new()),
	Recipe.new(Type.FIRE, Type.IRON_ORE, Type.IRON_ORE),
	Recipe.new(Type.COAL, Type.IRON_ORE, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.IRON_ORE, Type.HOT_STEEL),
	Recipe.new(Type.SAND, Type.IRON_ORE, Nothing.new()),
	Recipe.new(Type.GLASS, Type.IRON_ORE, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.IRON_ORE, Type.IRON_ORE),
	
	# Hot Steel
	Recipe.new(Type.STICKS, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.WOOD, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.STONE, Type.HOT_STEEL, Nothing.new()),
	Recipe.new(Type.BASKET, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.BUCKET, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.WATER_BUCKET, Type.HOT_STEEL, Type.STEEL),
	Recipe.new(Type.FIRE, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.COAL, Type.HOT_STEEL, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.SAND, Type.HOT_STEEL, Nothing.new()),
	Recipe.new(Type.GLASS, Type.HOT_STEEL, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.HOT_STEEL, Type.HOT_STEEL),
	Recipe.new(Type.HOT_STEEL, Type.HOT_STEEL, Type.HOT_STEEL),
	
	# Steel
	Recipe.new(Type.STICKS, Type.STEEL, Type.STEEL_AXE),
	Recipe.new(Type.WOOD, Type.STEEL, Type.STEEL_PICKAXE),
	Recipe.new(Type.STONE, Type.STEEL, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.STEEL, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.STEEL, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.STEEL, Nothing.new()),
	Recipe.new(Type.FIRE, Type.STEEL, Type.STEEL),
	Recipe.new(Type.COAL, Type.STEEL, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.STEEL, Type.HOT_STEEL),
	Recipe.new(Type.SAND, Type.STEEL, Type.BLADE),
	Recipe.new(Type.GLASS, Type.STEEL, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.STEEL, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.STEEL, Type.HOT_STEEL,
	Recipe.new(Type.STEEL, Type.STEEL, Type.STEEL),
	
	# Blade
	Recipe.new(Type.STICKS, Type.BLADE, Type.ARROW),
	Recipe.new(Type.WOOD, Type.BLADE, Type.SPEAR),
	Recipe.new(Type.STONE, Type.BLADE, Nothing.new()),
	Recipe.new(Type.BASKET, Type.BLADE, Nothing.new()),
	Recipe.new(Type.BUCKET, Type.BLADE, Nothing.new()),
	Recipe.new(Type.WATER_BUCKET, Type.BLADE, Nothing.new()),
	Recipe.new(Type.FIRE, Type.BLADE, Type.Blade),
	Recipe.new(Type.COAL, Type.BLADE, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.BLADE, Type.HOT_STEEL),
	Recipe.new(Type.SAND, Type.BLADE, Type.BLADE),
	Recipe.new(Type.GLASS, Type.BLADE, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.BLADE, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.BLADE, Type.HOT_STEEL),
	Recipe.new(Type.STEEL, Type.BLADE, Type.STEEL_BOOMERANG),
	Recipe.new(Type.BLADE, Type.BLADE, Type.SHURRIKEN),
	
	# Hammer
	Recipe.new(Type.STICKS, Type.HAMMER, Nothing.new()),
	Recipe.new(Type.WOOD, Type.HAMMER, Type.WOODEN_SHIELD),
	Recipe.new(Type.STONE, Type.HAMMER, Nothing.new()),
	Recipe.new(Type.BASKET, Type.HAMMER, Nothing.new()),
	Recipe.new(Type.BUCKET, Type.HAMMER, Nothing.new()),
	Recipe.new(Type.WATER_BUCKET, Type.HAMMER, Nothing.new()),
	Recipe.new(Type.FIRE, Type.HAMMER, Type.HAMMER),
	Recipe.new(Type.COAL, Type.HAMMER, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.HAMMER, Type.HAMMER),
	Recipe.new(Type.SAND, Type.HAMMER, Nothing.new()),
	Recipe.new(Type.GLASS, Type.HAMMER, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.HAMMER, Type.IRON_SHIELD),
	Recipe.new(Type.HOT_STEEL, Type.HAMMER, Type.SWORD),
	Recipe.new(Type.STEEL, Type.HAMMER, Type.CHAIN),
	Recipe.new(Type.BLADE, Type.HAMMER, Type.SICKLE),
	Recipe.new(Type.HAMMER, Type.HAMMER, Type.HAMMER),
	
	# Fiber
	Recipe.new(Type.STICKS, Type.FIBER, Type.FISHING_ROD),
	Recipe.new(Type.WOOD, Type.FIBER, Type.BOW),
	Recipe.new(Type.STONE, Type.FIBER, Type.STONE_SLING),
	#Recipe.new(Type.BASKET, Type.FIBER, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.FIBER, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.FIBER, Nothing.new()),
	Recipe.new(Type.FIRE, Type.FIBER, Type.FIRE),
	Recipe.new(Type.COAL, Type.FIBER, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.FIBER, Type.FIRE),
	Recipe.new(Type.SAND, Type.FIBER, Nothing.new()),
	Recipe.new(Type.GLASS, Type.FIBER, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.FIBER, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.FIBER, Nothing.new()),
	Recipe.new(Type.STEEL, Type.FIBER, Nothing.new()),
	Recipe.new(Type.BLADE, Type.FIBER, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.FIBER, Nothing.new()),
	Recipe.new(Type.FIBER, Type.FIBER, Type.NET),
	
	# Chain
	Recipe.new(Type.STICKS, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.WOOD, Type.CHAIN, Type.MORNING_STAR),
	Recipe.new(Type.STONE, Type.CHAIN, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.CHAIN, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.CHAIN, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.FIRE, Type.CHAIN, Type.CHAIN),
	Recipe.new(Type.COAL, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.CHAIN, Type.CHAIN),
	Recipe.new(Type.SAND, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.GLASS, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.STEEL, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.BLADE, Type.CHAIN, Type.CHAIN_BLADE),
	Recipe.new(Type.HAMMER, Type.CHAIN, Type.STEEL),
	Recipe.new(Type.FIBER, Type.CHAIN, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.CHAIN, Type.CHAINMAIL),
	
	# Sandstone
	Recipe.new(Type.STICKS, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.WOOD, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.STONE, Type.SANDSTONE, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.SANDSTONE, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.SANDSTONE, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.FIRE, Type.SANDSTONE, Type.SANDSTONE),
	Recipe.new(Type.COAL, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.SANDSTONE, Type.SANDSTONE),
	Recipe.new(Type.SAND, Type.SANDSTONE, Type.SANDSTONE),
	Recipe.new(Type.GLASS, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.STEEL, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.BLADE, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.SANDSTONE, Type.SAND),
	Recipe.new(Type.FIBER, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.SANDSTONE, Nothing.new()),
	Recipe.new(Type.SANDSTONE, Type.SANDSTONE, Type.SANDSTONE),
	
	# Leather
	Recipe.new(Type.STICKS, Type.LEATHER, Type.BATTLE_BANNER),
	Recipe.new(Type.WOOD, Type.LEATHER, Type.LEATHER_SHIELD),
	Recipe.new(Type.STONE, Type.LEATHER, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.LEATHER, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.LEATHER, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.LEATHER, Type.LEATHER),
	Recipe.new(Type.FIRE, Type.LEATHER, Type.LEATHER),
	Recipe.new(Type.COAL, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.LEATHER, Type.LEATHER),
	Recipe.new(Type.SAND, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.GLASS, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.STEEL, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.BLADE, Type.LEATHER, Type.LEATHER_SHIRT),
	Recipe.new(Type.HAMMER, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.FIBER, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.LEATHER, Type.WHIP),
	Recipe.new(Type.SANDSTONE, Type.LEATHER, Nothing.new()),
	Recipe.new(Type.LEATHER, Type.LEATHER, Type.EMPTY_QUIVER),
	
	# Diamond
	Recipe.new(Type.STICKS, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.WOOD, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.STONE, Type.DIAMOND, Type.RUNESTONE,
	#Recipe.new(Type.BASKET, Type.DIAMOND, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.DIAMOND, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.FIRE, Type.DIAMOND, Type.DIAMOND),
	Recipe.new(Type.COAL, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.DIAMOND, Type.DIAMOND),
	Recipe.new(Type.SAND, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.GLASS, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.STEEL, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.BLADE, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.FIBER, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.SANDSTONE, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.LEATHER, Type.DIAMOND, Nothing.new()),
	Recipe.new(Type.DIAMOND, Type.DIAMOND, Type.DIAMOND),
	
	# Runestone
	Recipe.new(Type.STICKS, Type.RUNESTONE, Type.WAND),
	Recipe.new(Type.WOOD, Type.RUNESTONE, Type.STAFF),
	Recipe.new(Type.STONE, Type.RUNESTONE, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.RUNESTONE, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.RUNESTONE, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.FIRE, Type.RUNESTONE, Type.RUNESTONE),
	Recipe.new(Type.COAL, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.RUNESTONE, Type.HOT_FIRE),
	Recipe.new(Type.SAND, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.GLASS, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.STEEL, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.BLADE, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.RUNESTONE, Type.DIAMOND),
	Recipe.new(Type.FIBER, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.SANDSTONE, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.LEATHER, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.DIAMOND, Type.RUNESTONE, Nothing.new()),
	Recipe.new(Type.RUNESTONE, Type.RUNESTONE, Type.RUNESTONE),
	
	# Empty Quiver
	Recipe.new(Type.STICKS, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.WOOD, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.STONE, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.BASKET, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.BUCKET, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.WATER_BUCKET, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.FIRE, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.COAL, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.SAND, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.GLASS, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.STEEL, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.BLADE, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.FIBER, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.SANDSTONE, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.LEATHER, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.DIAMOND, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.RUNESTONE, Type.EMPTY_QUIVER, Nothing.new()),
	Recipe.new(Type.EMPTY_QUIVER, Type.EMPTY_QUIVER, Type.EMPTY_QUIVER),
	
	# Arrow
	Recipe.new(Type.STICKS, Type.ARROW, Nothing.new()),
	Recipe.new(Type.WOOD, Type.ARROW, Nothing.new()),
	Recipe.new(Type.STONE, Type.ARROW, Nothing.new()),
	Recipe.new(Type.BASKET, Type.ARROW, Nothing.new()),
	Recipe.new(Type.BUCKET, Type.ARROW, Nothing.new()),
	Recipe.new(Type.WATER_BUCKET, Type.ARROW, Nothing.new()),
	Recipe.new(Type.FIRE, Type.ARROW, Nothing.new()),
	Recipe.new(Type.COAL, Type.ARROW, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.ARROW, Nothing.new()),
	Recipe.new(Type.SAND, Type.ARROW, Nothing.new()),
	Recipe.new(Type.GLASS, Type.ARROW, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.ARROW, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.ARROW, Nothing.new()),
	Recipe.new(Type.STEEL, Type.ARROW, Nothing.new()),
	Recipe.new(Type.BLADE, Type.ARROW, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.ARROW, Nothing.new()),
	Recipe.new(Type.FIBER, Type.ARROW, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.ARROW, Nothing.new()),
	Recipe.new(Type.SANDSTONE, Type.ARROW, Nothing.new()),
	Recipe.new(Type.LEATHER, Type.ARROW, Nothing.new()),
	Recipe.new(Type.DIAMOND, Type.ARROW, Nothing.new()),
	Recipe.new(Type.RUNESTONE, Type.ARROW, Nothing.new()),
	Recipe.new(Type.EMPTY_QUIVER, Type.ARROW, Type.QUIVER),
	Recipe.new(Type.ARROW, Type.ARROW, Type.ARROW),
	
	# Potion Base
	Recipe.new(Type.STICKS, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.WOOD, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.STONE, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.BASKET, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.BUCKET, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.WATER_BUCKET, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.FIRE, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.COAL, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.SAND, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.GLASS, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.STEEL, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.BLADE, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.FIBER, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.SANDSTONE, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.LEATHER, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.DIAMOND, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.RUNESTONE, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.EMPTY_QUIVER, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.ARROW, Type.POTION_BASE, Nothing.new()),
	Recipe.new(Type.POTION_BASE, Type.POTION_BASE, Nothing.new()),
	
	# Berries
	Recipe.new(Type.STICKS, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.WOOD, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.STONE, Type.BERRIES, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.BERRIES, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.BERRIES, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.FIRE, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.COAL, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.SAND, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.GLASS, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.STEEL, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.BLADE, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.FIBER, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.SANDSTONE, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.LEATHER, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.DIAMOND, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.RUNESTONE, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.EMPTY_QUIVER, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.ARROW, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.POTION_BASE, Type.BERRIES, Nothing.new()),
	Recipe.new(Type.BERRIES, Type.BERRIES, Type.BERRIES),

	# Herbs
	Recipe.new(Type.STICKS, Type.HERBS, Nothing.new()),
	Recipe.new(Type.WOOD, Type.HERBS, Nothing.new()),
	Recipe.new(Type.STONE, Type.HERBS, Nothing.new()),
	#Recipe.new(Type.BASKET, Type.HERBS, Type.BASKET_OF),
	#Recipe.new(Type.BUCKET, Type.HERBS, Type.BUCKET_OF),
	Recipe.new(Type.WATER_BUCKET, Type.HERBS, Nothing.new()),
	Recipe.new(Type.FIRE, Type.HERBS, Nothing.new()),
	Recipe.new(Type.COAL, Type.HERBS, Nothing.new()),
	Recipe.new(Type.HOT_FIRE, Type.HERBS, Nothing.new()),
	Recipe.new(Type.SAND, Type.HERBS, Nothing.new()),
	Recipe.new(Type.GLASS, Type.HERBS, Nothing.new()),
	Recipe.new(Type.IRON_ORE, Type.HERBS, Nothing.new()),
	Recipe.new(Type.HOT_STEEL, Type.HERBS, Nothing.new()),
	Recipe.new(Type.STEEL, Type.HERBS, Nothing.new()),
	Recipe.new(Type.BLADE, Type.HERBS, Nothing.new()),
	Recipe.new(Type.HAMMER, Type.HERBS, Nothing.new()),
	Recipe.new(Type.FIBER, Type.HERBS, Nothing.new()),
	Recipe.new(Type.CHAIN, Type.HERBS, Nothing.new()),
	Recipe.new(Type.SANDSTONE, Type.HERBS, Nothing.new()),
	Recipe.new(Type.LEATHER, Type.HERBS, Nothing.new()),
	Recipe.new(Type.DIAMOND, Type.HERBS, Nothing.new()),
	Recipe.new(Type.RUNESTONE, Type.HERBS, Nothing.new()),
	Recipe.new(Type.EMPTY_QUIVER, Type.HERBS, Nothing.new()),
	Recipe.new(Type.ARROW, Type.HERBS, Nothing.new()),
	Recipe.new(Type.POTION_BASE, Type.HERBS, Nothing.new()),
	Recipe.new(Type.BERRIES, Type.HERBS, Nothing.new()),
	Recipe.new(Type.HERBS, Type.HERBS, Type.HERBS),
]


static var decay := {
	Type.FIRE: Decay.new(10.0, Type.COAL),
	Type.TORCH: Decay.new(60.0, Type.COAL),
	Type.HOT_FIRE: Decay.new(10.0, Nothing.new()),
	Type.HOT_STEEL: Decay.new(20.0, Type.STEEL),
}

static var decay_sprites := {
	Type.FIRE: preload("res://effects/decay_fire_animation.tscn"),
	Type.HOT_STEEL: preload("res://effects/warm_steel_animation.tscn")
}

static var stat_modifiers := {
	Type.TRASH: StatModifier.new(0, -1),
	Type.WOOD: StatModifier.new(1, 0),
	Type.STONE: StatModifier.new(0, 0, false, 1),
	#STICKS,
	#BASKET,
	#BUCKET,
	#WATER_BUCKET,
	#STONE_AXE,
	#STONE_PICKAXE,
	Type.TORCH: StatModifier.new(0, 1, false, 0, false, 0, true),
	Type.COAL: StatModifier.new(0, 0, false, 1),
	Type.FIRE: StatModifier.new(-1, 0, true),
	Type.HOT_FIRE: StatModifier.new(-3, 0, true),
	#SAND,
	#MARACA,
	#SANDSTONE,
	#GLASS,
	#POTION_BASE,
	#HOURGLASS,
	Type.IRON_ORE: StatModifier.new(0, 0, false, 1),
	Type.HAMMER: StatModifier.new(0, 1),
	#SHOVEL,
	Type.HOT_STEEL: StatModifier.new(-2, 0),
	Type.STEEL: StatModifier.new(0, 0, false, 2),
	#STEEL_AXE,
	#STEEL_PICKAXE,
	#BLADE,
	#ARROW,
	Type.SPEAR: StatModifier.new(0, 2),
	#STEEL_BOOMERANG,
	#SHURRIKEN,
	Type.WOODEN_SHIELD: StatModifier.new(4, 0),
	Type.IRON_SHIELD: StatModifier.new(6, 0),
	Type.SWORD: StatModifier.new(0, 6),
	#CHAIN,
	#SICKLE,
	#FIBER,
	#FISHING_ROD,
	#BOW,
	#STONE_SLING,
	#NET,
	#MORNING_STAR,
	#CHAIN_BLADE,
	#CHAINMAIL,
	#LEATHER,
	#BATTLE_BANNER,
	#LEATHER_SHIELD,
	#LEATHER_SHIRT,
	#WHIP,
	#EMPTY_QUIVER,
	#QUIVER
	#DIAMOND,
	#RUNESTONE,
	#WAND,
	#STAFF,
	#BERRIES,
	#HERBS,
}


static var names := {
	Type.TRASH: "Trash",
	Type.WOOD: "Wood",
	Type.STONE: "Stone",
	Type.STICKS: "Sticks",
	Type.BASKET: "Basket",
	Type.BUCKET: "Bucket",
	Type.WATER_BUCKET: "Water Bucket",
	Type.STONE_AXE: "Stone Axe",
	Type.STONE_PICKAXE: "Stone Pickaxe",
	Type.TORCH: "Torch",
	Type.COAL: "Coal",
	Type.FIRE: "Fire",
	Type.HOT_FIRE: "Hot Fire",
	Type.SAND: "Sand",
	Type.MARACA: "Maraca",
	Type.SANDSTONE: "Sandstone",
	Type.GLASS: "Glass",
	Type.POTION_BASE: "Potion Base",
	Type.HOURGLASS: "Hourglass",
	Type.IRON_ORE: "Iron Ore",
	Type.HAMMER: "Hammer",
	Type.SHOVEL: "Shovel",
	Type.HOT_STEEL: "Hot Steel",
	Type.STEEL: "Steel",
	Type.STEEL_AXE: "Steel Axe",
	Type.STEEL_PICKAXE: "Steel Pickaxe",
	Type.BLADE: "Blade",
	Type.ARROW: "Arrow",
	Type.SPEAR: "Spear",
	Type.STEEL_BOOMERANG: "Steel Boomerang",
	Type.SHURRIKEN: "Shurriken",
	Type.WOODEN_SHIELD: "Wooden Shield",
	Type.IRON_SHIELD: "Iron Shield",
	Type.SWORD: "Sword",
	Type.CHAIN: "Chain",
	Type.SICKLE: "Sickle",
	Type.FIBER: "Fiber",
	Type.FISHING_ROD: "Fishing Rod",
	Type.BOW: "Bow",
	Type.STONE_SLING: "Stone Sling",
	Type.NET: "Net",
	Type.MORNING_STAR: "Morning Star",
	Type.CHAIN_BLADE: "Chain Blade",
	Type.CHAINMAIL: "Chainmail",
	Type.LEATHER: "Leather",
	Type.BATTLE_BANNER: "Battle Banner",
	Type.LEATHER_SHIELD: "Leather Shield",
	Type.LEATHER_SHIRT: "Leather Shirt",
	Type.WHIP: "Whip",
	Type.EMPTY_QUIVER: "Empty Quiver",
	Type.QUIVER: "Quiver",
	Type.DIAMOND: "Diamond",
	Type.RUNESTONE: "Runestone",
	Type.WAND: "Wand",
	Type.STAFF: "Staff",
	Type.BERRIES: "Berries",
	Type.HERBS: "Herbs",
}


static var descriptions := {
	Type.TRASH: "It's just garbage.",
	Type.WOOD: "Used for crafting.\n+1 Health",
	Type.STONE: "Used for crafting.\nCan be thrown for 1 damage.",
	#STICKS,
	#BASKET,
	#BUCKET,
	#WATER_BUCKET,
	#STONE_AXE,
	#STONE_PICKAXE,
	Type.TORCH: "+1 Damage\nEffective against bugs & plants.",
	Type.COAL: "Used for crafting.\nCan be thrown for 1 damage.",
	Type.FIRE: "Used for crafting.\nDoesn't last forever.",
	Type.HOT_FIRE: "Used for crafting.\nDoesn't last forever.",
	#SAND,
	#MARACA,
	#SANDSTONE,
	#GLASS,
	#POTION_BASE,
	#HOURGLASS,
	Type.IRON_ORE: "Used for crafting.\nCan be thrown for 1 damage.",
	Type.HAMMER: "Used for crafting.\n+1 Damage",
	#SHOVEL,
	Type.HOT_STEEL: "Used for crafting.\nDoesn't last forever.",
	Type.STEEL: "Used for crafting.\nCan be thrown for 2 damage.",
	#STEEL_AXE,
	#STEEL_PICKAXE,
	#BLADE,
	#ARROW,
	Type.SPEAR: "+2 Damage",
	#STEEL_BOOMERANG,
	#SHURRIKEN,
	Type.WOODEN_SHIELD: "+4 Health",
	Type.IRON_SHIELD: "+6 Health",
	Type.SWORD: "+6 Damage",
	#CHAIN,
	#SICKLE,
	#FIBER,
	#FISHING_ROD,
	#BOW,
	#STONE_SLING,
	#NET,
	#MORNING_STAR,
	#CHAIN_BLADE,
	#CHAINMAIL,
	#LEATHER,
	#BATTLE_BANNER,
	#LEATHER_SHIELD,
	#LEATHER_SHIRT,
	#WHIP,
	#EMPTY_QUIVER,
	#Quiver
	#DIAMOND,
	#RUNESTONE,
	#WAND,
	#STAFF,
	#BERRIES,
	#HERBS,
}


static var sprites := {
	Type.TRASH: preload('res://assets/items/trash.png'),
	Type.WOOD: preload('res://assets/items/wood.png'),
	Type.STONE: preload('res://assets/items/stone.png'),
	Type.STICKS: preload('res://assets/items/stick.png'),
	Type.BASKET: preload('res://assets/items/basket.png'),
	Type.BUCKET: preload('res://assets/items/bucket.png'),
	Type.WATER_BUCKET: preload('res://assets/items/empty.png'),
	Type.STONE_AXE: preload('res://assets/items/placeholder.png'),
	Type.STONE_PICKAXE: preload('res://assets/items/placeholder.png'),
	Type.TORCH: preload('res://assets/items/empty.png'),
	Type.COAL: preload('res://assets/items/coal.png'),
	Type.FIRE: preload('res://assets/items/empty.png'),
	Type.HOT_FIRE: preload('res://assets/items/empty.png'),
	Type.SAND: preload('res://assets/items/sand.png'),
	Type.MARACA: preload('res://assets/items/maraca.png'),
	Type.SANDSTONE: preload('res://assets/items/placeholder.png'),
	Type.GLASS: preload('res://assets/items/glass.png'),
	Type.POTION_BASE: preload('res://assets/items/empty.png'),
	Type.HOURGLASS: preload('res://assets/items/hourglass.png'),
	Type.IRON_ORE: preload('res://assets/items/iron_ore.png'),
	Type.HAMMER: preload('res://assets/items/hammer.png'),
	Type.SHOVEL: preload('res://assets/items/shovel.png'),
	Type.HOT_STEEL: preload('res://assets/items/empty.png'),
	Type.STEEL: preload('res://assets/items/steel.png'),
	Type.STEEL_AXE: preload('res://assets/items/placeholder.png'),
	Type.STEEL_PICKAXE: preload('res://assets/items/placeholder.png'),
	Type.BLADE: preload('res://assets/items/blade.png'),
	Type.ARROW: preload('res://assets/items/arrow.png'),
	Type.SPEAR: preload('res://assets/items/Spear.png'),
	Type.STEEL_BOOMERANG: preload('res://assets/items/boomerang.png'),
	Type.SHURRIKEN: preload('res://assets/items/placeholder.png'),
	Type.WOODEN_SHIELD: preload('res://assets/items/shield_wood.png'),
	Type.IRON_SHIELD: preload('res://assets/items/shield_iron.png'),
	Type.SWORD: preload('res://assets/items/sword.png'),
	Type.CHAIN: preload('res://assets/items/chain.png'),
	Type.SICKLE: preload('res://assets/items/sickle.png'),
	Type.FIBER: preload('res://assets/items/fiber.png'),
	Type.FISHING_ROD: preload('res://assets/items/placeholder.png'),
	Type.BOW: preload('res://assets/items/bow.png'),
	Type.STONE_SLING: preload('res://assets/items/placeholder.png'),
	Type.NET: preload('res://assets/items/net.png'),
	Type.MORNING_STAR: preload('res://assets/items/morning_star.png'),
	Type.CHAIN_BLADE: preload('res://assets/items/chain_blade.png'),
	Type.CHAINMAIL: preload('res://assets/items/chainmail.png'),
	Type.LEATHER: preload('res://assets/items/leather.png'),
	Type.BATTLE_BANNER: preload('res://assets/items/placeholder.png'),
	Type.LEATHER_SHIELD: preload('res://assets/items/placeholder.png'),
	Type.LEATHER_SHIRT: preload('res://assets/items/leather_shirt.png'),
	Type.WHIP: preload('res://assets/items/placeholder.png'),
	Type.EMPTY_QUIVER: preload('res://assets/items/empty_quiver.png'),
	Type.QUIVER: preload('res://assets/items/quiver.png'),
	Type.DIAMOND: preload('res://assets/items/diamond.png'),
	Type.RUNESTONE: preload('res://assets/items/empty.png'),
	Type.WAND: preload('res://assets/items/wand.png'),
	Type.STAFF: preload('res://assets/items/staff.png'),
	Type.BERRIES: preload('res://assets/items/placeholder.png'),
	Type.HERBS: preload('res://assets/items/placeholder.png'),
}

static var small_sprites := {
	Type.TRASH: preload('res://assets/items/small_items/small_trash.png'),
	Type.WOOD: preload('res://assets/items/small_items/small_wood.png'),
	Type.STONE: preload('res://assets/items/small_items/small_stone.png'),
	Type.STICKS: preload('res://assets/items/small_items/small_stick.png'),
	Type.BASKET: preload('res://assets/items/small_items/small_basket.png'),
	Type.BUCKET: preload('res://assets/items/small_items/small_bucket.png'),
	Type.WATER_BUCKET: preload('res://assets/items/small_items/small_water_bucket.png'),
	Type.STONE_AXE: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.STONE_PICKAXE: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.TORCH: preload('res://assets/items/small_items/small_torch.png'),
	Type.COAL: preload('res://assets/items/small_items/small_coal.png'),
	Type.SAND: preload('res://assets/items/small_items/small_sand.png'),
	Type.MARACA: preload('res://assets/items/small_items/small_maraca.png'),
	Type.SANDSTONE: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.GLASS: preload('res://assets/items/small_items/small_glass.png'),
	Type.POTION_BASE: preload('res://assets/items/small_items/small_potion_base.png'),
	Type.HOURGLASS: preload('res://assets/items/small_items/small_hourglass.png'),
	Type.IRON_ORE: preload('res://assets/items/small_items/small_iron_ore.png'),
	Type.HAMMER: preload('res://assets/items/small_items/small_hammer.png'),
	Type.SHOVEL: preload('res://assets/items/small_items/small_shovel.png'),
	Type.HOT_STEEL: preload('res://assets/items/small_items/small_hot_steel.png'),
	Type.STEEL: preload('res://assets/items/small_items/small_steel.png'),
	Type.STEEL_AXE: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.STEEL_PICKAXE: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.BLADE: preload('res://assets/items/small_items/small_blade.png'),
	Type.ARROW: preload('res://assets/items/small_items/small_arrow.png'),
	Type.SPEAR: preload('res://assets/items/small_items/small_Spear.png'),
	Type.STEEL_BOOMERANG: preload('res://assets/items/small_items/small_boomerang.png'),
	Type.SHURRIKEN: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.WOODEN_SHIELD: preload('res://assets/items/small_items/small_shield_wood.png'),
	Type.IRON_SHIELD: preload('res://assets/items/small_items/small_shield_iron.png'),
	Type.SWORD: preload('res://assets/items/small_items/small_sword.png'),
	Type.CHAIN: preload('res://assets/items/small_items/small_chain.png'),
	Type.SICKLE: preload('res://assets/items/small_items/small_sickle.png'),
	Type.FIBER: preload('res://assets/items/small_items/small_fiber.png'),
	Type.FISHING_ROD: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.BOW: preload('res://assets/items/small_items/small_bow.png'),
	Type.STONE_SLING: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.NET: preload('res://assets/items/small_items/small_net.png'),
	Type.MORNING_STAR: preload('res://assets/items/small_items/small_morning_star.png'),
	Type.CHAIN_BLADE: preload('res://assets/items/small_items/small_chain_blade.png'),
	Type.CHAINMAIL: preload('res://assets/items/small_items/small_chainmail.png'),
	Type.LEATHER: preload('res://assets/items/small_items/small_leather.png'),
	Type.BATTLE_BANNER: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.LEATHER_SHIELD: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.LEATHER_SHIRT: preload('res://assets/items/small_items/small_leather_shirt.png'),
	Type.WHIP: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.EMPTY_QUIVER: preload('res://assets/items/small_items/small_empty_quiver.png'),
	Type.QUIVER: preload('res://assets/items/small_items/small_quiver.png'),
	Type.DIAMOND: preload('res://assets/items/small_items/small_diamond.png'),
	Type.RUNESTONE: preload('res://assets/items/small_items/small_runestone.png'),
	Type.WAND: preload('res://assets/items/small_items/small_wand.png'),
	Type.STAFF: preload('res://assets/items/small_items/small_staff.png'),
	Type.BERRIES: preload('res://assets/items/small_items/small_placeholder.png'),
	Type.HERBS: preload('res://assets/items/small_items/small_placeholder.png'),
}


static var effects := {
	Type.TRASH: null,
	Type.WOOD: null,
	Type.STONE: null,
	Type.STICKS: null,
	Type.BASKET: null,
	Type.BUCKET: null,
	Type.WATER_BUCKET: null, # ANIMATION TODO
	Type.STONE_AXE: null,
	Type.STONE_PICKAXE: null,
	Type.TORCH: preload("res://effects/torch_animation.tscn"),
	Type.COAL: null,
	Type.FIRE: preload("res://effects/fire_animation.tscn"),
	Type.HOT_FIRE: preload("res://effects/blue_fire_animation.tscn"),
	Type.SAND: null,
	Type.MARACA: null,
	Type.SANDSTONE: null,
	Type.GLASS: null,
	Type.POTION_BASE: null,  # ANIMATION TODO
	Type.HOURGLASS: null,
	Type.IRON_ORE: null,
	Type.HAMMER: null,
	Type.SHOVEL: null,
	Type.HOT_STEEL: preload("res://effects/hot_steel_animation.tscn"),
	Type.STEEL: null,
	Type.STEEL_AXE: null,
	Type.STEEL_PICKAXE: null,
	Type.BLADE: null,
	Type.ARROW: null,
	Type.SPEAR: null,
	Type.STEEL_BOOMERANG: null,
	Type.SHURRIKEN: null,
	Type.WOODEN_SHIELD: null,
	Type.IRON_SHIELD: null,
	Type.SWORD: null,
	Type.CHAIN: null,
	Type.SICKLE: null,
	Type.FIBER: null,
	Type.FISHING_ROD: null,
	Type.BOW: null,
	Type.STONE_SLING: null,
	Type.NET: null,
	Type.MORNING_STAR: null,
	Type.CHAIN_BLADE: null,
	Type.CHAINMAIL: null,
	Type.LEATHER: null,
	Type.BATTLE_BANNER: null,
	Type.LEATHER_SHIELD: null,
	Type.LEATHER_SHIRT: null,
	Type.WHIP: null,
	Type.EMPTY_QUIVER: null,
	Type.QUIVER: null,
	Type.DIAMOND: null,
	Type.RUNESTONE: null,  # ANIMATION TODO
	Type.WAND: null,
	Type.STAFF: null,
	Type.BERRIES: null,
	Type.HERBS: null,

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
