# death_screen.gd
extends CanvasLayer

@onready var music = $AudioStreamPlayer

func _ready():
	# Pausar el juego al mostrar la pantalla
	get_tree().paused = true
	music.play()

func _on_retry_button_pressed():
	get_tree().paused = false
	GameState.vidas_juego = 5        # resetear vidas
	GameState.resetear_nivel()  
	GameState.checkpoint_activo = false 
	queue_free()  
	get_tree().change_scene_to_file("res://Menús/escenas/level_selector.tscn")

func _on_menu_button_pressed():
	get_tree().paused = false
	GameState.vidas_juego = 5        # resetear vidas
	GameState.resetear_nivel()
	GameState.checkpoint_activo = false 
	queue_free()   
	get_tree().change_scene_to_file("res://Menús/escenas/principal.tscn")
