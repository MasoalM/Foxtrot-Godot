extends Area2D

@export var fuerza = 1200

func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.velocity.y -= fuerza * delta
