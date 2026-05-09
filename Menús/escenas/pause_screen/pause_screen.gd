extends CanvasLayer

@onready var pausa = $"Control/Fondo/Menú de pausa"
@onready var ajustes = $"Control/Fondo/Menú Ajustes"
@onready var salida = $"Control/Fondo/Menú de salida"

@onready var selected_label = $"Control/Fondo/Menú de pausa/InfoCargar/Partida seleccionada"
@onready var play_time = $"Control/Fondo/Menú de pausa/InfoCargar/Tiempo de juego"
@onready var last_time_played = $"Control/Fondo/Menú de pausa/InfoCargar/Última vez"
@onready var lives = $"Control/Fondo/Menú de pausa/InfoCargar/Vidas"
@onready var max_level = $"Control/Fondo/Menú de pausa/InfoCargar/Nivel alcanzado"
@onready var collectibles = $"Control/Fondo/Menú de pausa/InfoCargar/Coleccionables"

var pointer_texture = preload("res://Sprites/Pointer.png")

func _ready():
	UIManager.register_buttons(self)
	_set_process_always(self)
	visible = false
	
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_POINTING_HAND)

func _set_process_always(node):
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in node.get_children():
		_set_process_always(child)

# -- Pause Menu Handler --

func show_menu():
	visible = true
	
	# Show game info
	var slot_save: SaveData = SaveManager.save_data
	
	if slot_save:
		selected_label.text = "PARTIDA: " + slot_save.title
		SaveManager.set_info(play_time, Utils.format_play_time(slot_save.play_time))
		SaveManager.set_info(last_time_played, Utils.format_time(slot_save.last_time_played))
		SaveManager.set_info(lives, str(slot_save.lives))
		SaveManager.set_info(max_level, str(slot_save.max_level))
		SaveManager.set_info(collectibles, str(slot_save.get_total_collected()))

func hide_menu():
	visible = false

func is_on_submenu():
	return ajustes.visible or salida.visible

func back_to_main():
	pausa.visible = true
	salida.visible = false
	ajustes.visible = false
	
	AudioManager.play("back_click")

func handle_leaving():
	PauseManager.resume()
	
	GameState.resetear_nivel()
	GameState.checkpoint_activo = false
	GameState.tiempo_activo = false
	
	pausa.visible = true
	salida.visible = false

# -- Botones --

# Botones del menú de pausa

func _on_reanudar_pressed() -> void:
	print("REANUDAR")
	PauseManager.resume()
	AudioManager.play("click")

func _on_ajustes_pressed() -> void:
	pausa.visible = false
	ajustes.visible = true
	
	AudioManager.play("click")

func _on_salir_pressed() -> void:
	pausa.visible = false
	salida.visible = true
	
	AudioManager.play("click")

# Botones del menú de salida

func _on_selector_de_niveles_pressed() -> void:
	handle_leaving()
	get_tree().change_scene_to_file("res://niveles/level_selector.tscn")
	
	AudioManager.play("click")

func _on_menú_principal_pressed() -> void:
	handle_leaving()
	get_tree().change_scene_to_file("res://Menús/escenas/principal.tscn")
	
	AudioManager.play("click")

func _on_salir_al_escritorio_pressed() -> void:
	get_tree().quit()

func _on_atrás_pressed() -> void:
	back_to_main()
