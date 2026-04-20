extends VBoxContainer

var pointer_texture = preload("res://Sprites/Pointer.png")

func _ready():
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_POINTING_HAND)
	
	UIManager.register_buttons(self)

# -- Acciones --

# General Button Handler
func _global_pressed() -> void:
	AudioManager.play("menu_principal_click")

# Cargar Partida
func _on_cargar_partida_pressed() -> void:
	print("PRESIONADO: CARGAR PARTIDA")
	_global_pressed()
	get_tree().change_scene_to_file("res://Menús/escenas/partidas/partidas.tscn")

# Nueva Partida
func _on_nueva_partida_pressed() -> void:
	print("PRESIONADO: NUEVA PARTIDA")
	_global_pressed()
	get_tree().change_scene_to_file("res://niveles/level_selector.tscn")

# Ajustes
func _on_ajustes_pressed() -> void:
	print("PRESIONADO: AJUSTES")
	_global_pressed()
	get_tree().change_scene_to_file("res://Menús/escenas/ajustes/ajustes.tscn")

# Salir
func _on_salir_pressed() -> void:
	print("PRESIONADO: SALIR")
	get_tree().quit()


# -- H  --

func _on_mox_nose_pressed() -> void:
	AudioManager.play("mox_nose", )
