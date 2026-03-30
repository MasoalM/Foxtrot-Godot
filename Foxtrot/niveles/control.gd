extends Control

@onready var corazones = $HBoxContainer.get_children()

var corazon_rojo = preload("res://hud/Heart2.png")
var corazon_gris = preload("res://hud/ProtectedHeart.png")

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.vidas_cambiadas.connect(actualizar_vidas)
		actualizar_vidas(player.vidas)

func actualizar_vidas(vidas):
	for i in range(corazones.size()):
		if i < vidas:
			corazones[i].texture = corazon_rojo
		else:
			corazones[i].texture = corazon_gris
