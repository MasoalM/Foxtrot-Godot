extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("a")
	if body.has_method("_muerte_instantanea"):
		print("b")
		body._muerte_instantanea()
