extends CanvasLayer

@onready var pausa = $"Control/Fondo/Menú de pausa"
@onready var salida = $"Control/Fondo/Menú de salida"

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

func hide_menu():
	visible = false

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
	pausa.visible = true
	salida.visible = false
	
	AudioManager.play("click")
