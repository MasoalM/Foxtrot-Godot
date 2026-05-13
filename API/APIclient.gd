extends Node

var url_base = "https://antiquewhite-cattle-735083.hostingersite.com/api/"

func enviar_resultado(data: Dictionary):
	var http = HTTPRequest.new()
	add_child(http)

	var url = url_base + "save_progress.php"

	var json = JSON.stringify(data)

	var headers = [
		"Content-Type: application/json"
	]

	http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json
	)

	http.request_completed.connect(_on_request_completed)


func _on_request_completed(_result, response_code, _headers, body):

	print("HTTP CODE:", response_code)

	var texto = body.get_string_from_utf8()

	print("Respuesta servidor:", texto)
