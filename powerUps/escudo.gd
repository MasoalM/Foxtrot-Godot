extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print(body.get_groups())
	if body.is_in_group("player"):
		body.apply_powerup("escudo")
		get_parent().queue_free()

func _on_area_entered(area: Area2D) -> void:
	print(area.get_groups())
	if area.is_in_group("player"):
		area.apply_powerup("escudo")
		get_parent().queue_free()
