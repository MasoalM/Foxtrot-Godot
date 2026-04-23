extends Node

var url_base = "http://localhost/api/"

func enviar_resultado(data: Dictionary):
	var http = HTTPRequest.new()
	add_child(http)

	var url = url_base + "save_progress.php"

	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]

	http.request(url, headers, HTTPClient.METHOD_POST, json)

	http.request_completed.connect(_on_request_completed)


func _on_request_completed(result, response_code, headers, body):
	var texto = body.get_string_from_utf8()
	print("Respuesta servidor:", texto)
