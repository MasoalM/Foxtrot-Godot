extends Control

@onready var corazones = $HBoxContainer.get_children()

var corazon_rojo = preload("res://hud/Heart2.png")
var corazon_gris = preload("res://hud/ProtectedHeart.png")
var corazon_escudo = preload("res://Sprites/Tiles/Default/gem_blue.png") 

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.vidas_cambiadas.connect(actualizar_vidas)
		actualizar_vidas(player.vidas, player.escudo)

func actualizar_vidas(vidas, escudo):
	var total = corazones.size()

	for i in range(total):
		# Primero escudo (tiene prioridad visual)
		if i < escudo:
			corazones[i].texture = corazon_escudo
		
		# Luego vida
		elif i < escudo + vidas:
			corazones[i].texture = corazon_rojo
		
		# Vacío
		else:
			corazones[i].texture = corazon_gris
