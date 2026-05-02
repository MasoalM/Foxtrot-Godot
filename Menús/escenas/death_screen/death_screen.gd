extends CanvasLayer

@onready var music = $AudioStreamPlayer
var pointer_texture = preload("res://Sprites/Pointer.png")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_POINTING_HAND)
	
	# Pausar el juego al mostrar la pantalla
	get_tree().paused = true
	music.play()

func _on_retry_button_pressed():
	get_tree().paused = false
	GameState.resetear_nivel()
	
	queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene_to_file("res://niveles/level_selector.tscn")

func _on_menu_button_pressed():
	get_tree().paused = false
	GameState.resetear_nivel()
	
	queue_free()
	get_tree().change_scene_to_file("res://Menús/escenas/principal.tscn")
