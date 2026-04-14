extends Area2D

@export var fuerza_max = 1400.0
@export var velocidad_y_max = -600.0  # techo de impulso hacia arriba

func _process(delta):
	# Leer intensidad del géiser padre (0.0 a 1.0)
	var intensidad = get_parent().altura_actual / get_parent().altura_max

	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			var fuerza_actual = fuerza_max * intensidad
			body.velocity.y -= fuerza_actual * delta
			# Limitar para no salir disparado
			body.velocity.y = max(body.velocity.y, velocidad_y_max)
