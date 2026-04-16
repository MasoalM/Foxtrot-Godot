extends Control

@onready var corazones = $HBoxContainer.get_children()
@onready var monedas = $HBoxContainerMonedas.get_children()
@onready var fondo = $TextureRect
@onready var label_ups = $HBoxContainerUP/Label
@onready var label_time = $HBoxContainerTime/time
var fullvida = preload("res://hud/MoxFullHealthBar.png")
var damagedvida = preload("res://hud/MoxDamagedHealthBar.png")
var vidaescudo = preload("res://hud/MoxProtectedHealthBar.png")

var corazon_rojo = preload("res://hud/Heart2.png")
var corazon_gris = preload("res://hud/ProtectedHeart.png")
var corazon_escudo = preload("res://hud/ShieldHeart.png") 

var moneda_textura = preload("res://Sprites/Coleccionables/Coleccionable.png")

func _ready():
	GameState.tiempo_cambiado.connect(actualizar_tiempo)
	actualizar_tiempo(GameState.tiempo_restante)
	GameState.vidas_juego_cambiadas.connect(actualizar_ups)
	actualizar_ups(GameState.vidas_juego)
	for moneda in monedas:
		moneda.texture = moneda_textura
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.vidas_cambiadas.connect(actualizar_vidas)
		GameState.monedas_cambiadas.connect(actualizar_monedas)
		actualizar_monedas(GameState.monedas_estado)
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
	
	if escudo > 0:
		fondo.texture = vidaescudo
	else:
		if vidas == max_vidas:
			fondo.texture = fullvida
		else:
			fondo.texture = damagedvida			
			
func actualizar_monedas(monedas_estado):
	for i in range(monedas.size()):
		monedas[i].texture = moneda_textura  # siempre la misma
		
		if monedas_estado[i]:
			# color normal
			monedas[i].modulate = Color(1, 1, 1)
		else:
			# gris (no recogida)
			monedas[i].modulate = Color(0.3, 0.3, 0.3)		
func actualizar_ups(vidas_juego):
	label_ups.text = "  x" + str(vidas_juego)		
	
func actualizar_tiempo(tiempo):
	label_time.text = "time :  "+str(tiempo)		
