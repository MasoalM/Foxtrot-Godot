extends Area2D

@export var speed := 80.0

func _process(delta):
	if position.y>-5250:
		position.y -= speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("_die"):
		body._die()
