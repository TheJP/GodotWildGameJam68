class_name GameParameters

static var tilesize := 64.0
static var craft_tilesize := 64.0
static var buildable_space := Vector4(0, 0, 1920, 896)


static func is_buildable(position: Vector2):
	return (buildable_space.x <= position.x and position.x < (buildable_space.x + buildable_space.z) and
		buildable_space.y <= position.y and position.y < (buildable_space.y + buildable_space.w))

