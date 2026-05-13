extends Node

@onready var indicador: Sprite2D = $Indicador

#func _ready() -> void:
#	indicador.visible = false  # Oculto al inicio

func _on_area_2d_body_entered(body):
	print("body entró: ", body.name)
	if body.is_in_group("player"):
		indicador.visible = true  # Mostrar imagen

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		indicador.visible = false  # Ocultar imagen
