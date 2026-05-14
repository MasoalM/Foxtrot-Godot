extends Control

@onready var corazones = $HBoxContainer.get_children()
@onready var monedas = $HBoxContainerMonedas.get_children()
@onready var fondo = $TextureRect
@onready var label_ups = $VBoxContainer/HBoxContainerUP/textoVidas
@onready var label_time = $VBoxContainer/HBoxContainerTime/time
@onready var label_puntos = $VBoxContainer/HBoxContainerPuntos/textoPuntuacion
@onready var label_ranas = $VBoxContainer/HBoxContainerRanas/textoRanas

var fullvida = preload("res://hud/MoxFullHealthBar.png")
var damagedvida = preload("res://hud/MoxDamagedHealthBar.png")
var vidaescudo = preload("res://hud/MoxProtectedHealthBar.png")
var corazon_rojo = preload("res://hud/Heart2.png")
var corazon_gris = preload("res://hud/ProtectedHeart.png")
var corazon_escudo = preload("res://hud/ShieldHeart.png")
var moneda_textura = preload("res://Sprites/Coleccionables/Coleccionable.png")

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	GameState.tiempo_activo = true
	GameState.tiempo_cambiado.connect(actualizar_tiempo)
	actualizar_tiempo(GameState.tiempo_restante)

	GameState.vidas_juego_cambiadas.connect(actualizar_ups)
	actualizar_ups(GameState.vidas_juego)

	GameState.puntuacion_cambiada.connect(actualizar_puntuacion)
	actualizar_puntuacion(GameState.puntuacion)

	# NUEVO
	GameState.ranas_cambiadas.connect(actualizar_ranas)
	actualizar_ranas(GameState.ranas)

	for moneda in monedas:
		moneda.texture = moneda_textura

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.vidas_cambiadas.connect(actualizar_vidas)
		GameState.monedas_cambiadas.connect(actualizar_monedas)
		actualizar_monedas(GameState.monedas_estado)
		actualizar_vidas(player.vidas, player.escudo)

func actualizar_puntuacion(puntos):
	label_puntos.text = str(puntos)

func actualizar_ranas(total: int):  # NUEVO
	label_ranas.text = "x" + str(total)

func actualizar_vidas(vidas, escudo):
	var max_vidas = 2
	var max_escudo = 2

	vidas = clamp(vidas, 0, max_vidas)
	escudo = clamp(escudo, 0, max_escudo)

	var total = corazones.size()

	for i in range(total):
		if i < max_vidas:
			corazones[i].visible = true
			if i < vidas:
				corazones[i].texture = corazon_rojo
			else:
				corazones[i].texture = corazon_gris
		else:
			var index_escudo = i - max_vidas
			if escudo == 0:
				corazones[i].visible = false
				continue
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
		monedas[i].texture = moneda_textura
		if monedas_estado[i]:
			monedas[i].modulate = Color(1, 1, 1)
		else:
			monedas[i].modulate = Color(0.3, 0.3, 0.3)

func actualizar_ups(vidas_juego):
	label_ups.text = "x" + str(vidas_juego)

func actualizar_tiempo(tiempo):
	label_time.text = str(tiempo)

func enviar_resultado(nivel_id: int, puntos: int, jugador_id: int):
	var http = HTTPRequest.new()
	add_child(http)

	var url = "http://localhost/api/guardar_progreso.php"

	var data = {
		"jugador_id": jugador_id,
		"nivel_id": nivel_id,
		"tiempo": GameState.tiempo_restante,
		"puntos": puntos,
		"coleccionables": GameState.monedas_estado
	}

	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]

	http.request(url, headers, HTTPClient.METHOD_POST, json)
	http.request_completed.connect(_on_request_completed)

func _on_request_completed(_result, _response_code, _headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	print("Respuesta servidor: ", response)
