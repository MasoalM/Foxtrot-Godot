extends Node

var url_base = "https://antiquewhite-cattle-735083.hostingersite.com/api/"

@onready var http = HTTPRequest.new()

signal player_login_completed(success)


func _ready():

	add_child(http)

	http.request_completed.connect(
		_on_request_completed
	)


# =========================================================
# GUARDAR PROGRESO
# =========================================================

func enviar_resultado(data: Dictionary):

	print("==============")
	print("ENVIANDO RESULTADO")

	var url = url_base + "save_progress.php"

	var json = JSON.stringify(data)

	print("JSON:")
	print(json)

	var headers = [
		"Content-Type: application/json"
	]

	var error = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json
	)

	print("REQUEST ERROR:", error)


# =========================================================
# CREAR / OBTENER JUGADOR
# =========================================================

func get_or_create_player(nombre: String):

	print("==============")
	print("INICIANDO REQUEST")

	print("Nombre:", nombre)

	var url = url_base + "get_or_create_player.php"

	print("URL:", url)

	var data = {
		"nombre": nombre
	}

	var json = JSON.stringify(data)

	print("JSON:", json)

	var headers = [
		"Content-Type: application/json"
	]

	var error = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json
	)

	print("REQUEST ERROR:", error)


# =========================================================
# RESPUESTA SERVIDOR
# =========================================================

func _on_request_completed(
	result,
	response_code,
	headers,
	body
):

	print("==============")
	print("REQUEST COMPLETADA")

	print("RESULT:", result)

	print("HTTP CODE:", response_code)

	print("HEADERS:", headers)

	var texto = body.get_string_from_utf8()

	print("RAW BODY:")
	print(texto)

	var json = JSON.parse_string(texto)

	print("JSON PARSEADO:")
	print(json)

	if json == null:

		print("JSON INVALIDO")

		emit_signal(
			"player_login_completed",
			false
		)

		return

	# =====================================================
	# LOGIN JUGADOR
	# =====================================================

	if json.has("id") and json.has("nombre"):

		GameState.jugador_id = json["id"]

		GameState.nombre = json["nombre"]

		print("==============")
		print("LOGIN OK")

		print("PLAYER ID:", GameState.jugador_id)

		print("PLAYER NAME:", GameState.nombre)

		emit_signal(
			"player_login_completed",
			true
		)

	# =====================================================
	# SAVE PROGRESS
	# =====================================================

	if json.has("status"):

		print("STATUS:", json["status"])
