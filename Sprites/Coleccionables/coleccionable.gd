extends Area2D

@export var value := 1

@export var coin_id := 0  # 0, 1, 2 (orden del nivel)

func _on_body_entered(body):
	print(body.name, " - ", body.get_class())
	if body.is_in_group("player"):
		body.recoger_moneda(coin_id)
		queue_free()

func recoger(player):
	player.add_coin(value) 
	queue_free()
