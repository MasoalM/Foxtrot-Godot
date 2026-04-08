extends Node2D
@export var escena_destino: String

func _ready() -> void:
	pass # Replace with function body.

func entrar_al_nivel():
	print("Entrando al nivel…")  # Aquí va la lógica real para cambiar de nivel
	# Por ejemplo:
	get_tree().change_scene("res://niveles/nivel1_beta.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
