extends Area2D

@export var value := 1
@export var coin_id := 0  # 0, 1, 2

var popup_scene = preload("res://personaje/PointPopup.tscn")

func _on_body_entered(body):
	print(body.name, " - ", body.get_class())
	
	if body.is_in_group("player"):
		
		# PUNTOS
		GameState.sumar_puntos(100)

		# POPUP VISUAL
		var popup = popup_scene.instantiate()
		get_tree().current_scene.add_child(popup)

		popup.global_position = global_position + Vector2(0, -30)

		popup.setup("+100")

		# MONEDA
		body.recoger_moneda(coin_id)

		queue_free()

func recoger(player):
	player.add_coin(value)
	queue_free()
