extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	print(body.get_groups())
	if body.is_in_group("player"):
		body.apply_powerup("escudo")
		get_parent().queue_free()
	pass	


func _on_area_entered(area: Area2D) -> void:
	print(area.get_groups())
	if area.is_in_group("player"):
		area.apply_powerup("escudo")
		get_parent().queue_free()
	pass 
