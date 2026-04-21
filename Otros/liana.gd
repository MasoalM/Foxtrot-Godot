extends Node2D

func _physics_process(_delta):
	for child in get_children():
		if child is RigidBody2D:
			child.angular_velocity = 0.0  # impedir rotación de segmentos

func recibir_inercia(vel: Vector2) -> void:
	for child in get_children():
		if child is RigidBody2D:
			child.apply_central_impulse(Vector2(vel.x * 0.3, 0))
