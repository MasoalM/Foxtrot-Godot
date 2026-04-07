extends Area2D

func _ready() -> void:
	add_to_group("vida")

func _on_body_entered(body: Node2D) -> void:
	print(body.get_groups())
	if body.is_in_group("player"):
		body.apply_powerup("vida")
		get_parent().queue_free() 
