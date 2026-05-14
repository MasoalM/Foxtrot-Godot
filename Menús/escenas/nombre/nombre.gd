extends CanvasLayer

@onready var input_nick = $nombreEscena/Botones/LineEdit


func _ready():

	input_nick.grab_focus()

	APIclient.player_login_completed.connect(
		_on_login_completed
	)

func _on_continuar_pressed() -> void:
	print("llego hasta antes de llamar a la api")

	var nick = input_nick.text.strip_edges()

	if nick == "":
		return

	APIclient.get_or_create_player(nick)


	


func _on_login_completed(success):

	if success:

		print("LOGIN TERMINADO")

		print("ID JUGADOR:", GameState.jugador_id)

		print("NOMBRE:", GameState.nombre)

		get_tree().change_scene_to_file("res://Menús/escenas/principal.tscn")

	else:

		print("ERROR LOGIN")
