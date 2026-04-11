extends Area2D

var yaGolpeo = false

func _ready():
	add_to_group("ProyectilAliado")

	await get_tree().create_timer(0.2).timeout
	queue_free()


		
