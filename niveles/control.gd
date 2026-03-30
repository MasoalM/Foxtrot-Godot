extends Control

@onready var corazones = $HBoxContainer.get_children()

var corazon_rojo = preload("res://hud/Heart2.png")
var corazon_gris = preload("res://hud/ProtectedHeart.png")
var corazon_escudo = preload("res://hud/ShieldHeart.png") 

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.vidas_cambiadas.connect(actualizar_vidas)
		actualizar_vidas(player.vidas, player.escudo)

func actualizar_vidas(vidas, escudo):
	var max_vidas = 2
	var max_escudo = 2

	vidas = clamp(vidas, 0, max_vidas)
	escudo = clamp(escudo, 0, max_escudo)

	var total = corazones.size()

	for i in range(total):

		#  VIDAS (siempre visibles)
		if i < max_vidas:
			corazones[i].visible = true
			
			if i < vidas:
				corazones[i].texture = corazon_rojo
			else:
				corazones[i].texture = corazon_gris

		#  ESCUDO
		else:
			var index_escudo = i - max_vidas

			# ocultar slots de escudos no usados
			if escudo == 0:
				corazones[i].visible = false
				continue

			# mostrar solo los necesarios
			if index_escudo < escudo:
				corazones[i].visible = true
				corazones[i].texture = corazon_escudo
			else:
				corazones[i].visible = false
