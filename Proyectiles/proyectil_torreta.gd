extends Area2D

const dist_max = 180.0
var vel_bala = 600.0
var direccion = Vector2(1, 0)  # ← dirección, la torreta la sobreescribe
var dist = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if visible:
		position += direccion * vel_bala * delta  # ← usa el vector
		dist += 1
		if dist > dist_max:
			morir()

func morir():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body._dañar()
	morir()
	
