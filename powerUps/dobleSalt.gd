extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.apply_powerup("dobSal")
		get_parent().queue_free()
