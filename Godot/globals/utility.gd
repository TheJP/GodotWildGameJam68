extends Node

func viewport_to_world(p_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * p_position
