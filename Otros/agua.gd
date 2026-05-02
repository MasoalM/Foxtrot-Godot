extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_water"):
		body.set_water()

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_waterf"):
		body.set_waterf()
