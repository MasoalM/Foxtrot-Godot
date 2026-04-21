extends Node2D



func recibir_inercia(vel: Vector2) -> void:
	print("THe END IS NEVER")
	for child in get_children():
		if child is RigidBody2D:
			child.apply_central_impulse(Vector2(vel.x * 0.3, 0))
