extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("vida")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print(body.get_groups())
	if body.is_in_group("player"):
		body.apply_powerup("vida")
		get_parent().queue_free() 
