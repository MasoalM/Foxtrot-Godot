extends Area2D

const dist_max = 1088.0
var vel_bala = 600.0
var direccion = Vector2(1, 0)
var dist = 0.0

func _process(delta: float) -> void:
	if visible:
		var movimiento = direccion * vel_bala * delta
		
		position += movimiento
		dist += movimiento.length() # suma la distancia real recorrida
		
		if dist >= dist_max:
			morir()

func morir():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body._dañar()
	morir()
	
