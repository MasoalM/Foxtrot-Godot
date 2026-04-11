extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("paso1")
		body.apply_powerup("guante")
		print("paso2")
		queue_free()
