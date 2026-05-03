extends Area2D

@export var fuerza_max = 1400.0
@export var velocidad_y_max = -600.0  # techo de impulso hacia arriba

func _process(delta):
	# Leer intensidad del géiser padre (0.0 a 1.0)
	var intensidad = get_parent().altura_actual / get_parent().altura_max

	
