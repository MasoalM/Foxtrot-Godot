extends Area2D

const dist_max = 45.0

var vel_bala = 600.0
var dist = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ProyectilAliado")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += vel_bala * delta
	dist += 1
	if dist > dist_max:
		morir()
	
func morir():
	remove_from_group("ProyectilAliado")
	queue_free()
