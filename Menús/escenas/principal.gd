extends VBoxContainer

@onready var sprite = $"../Mox Nose/AnimatedSprite2D"
var pointer_texture = preload("res://Sprites/Pointer.png")

func _ready():
	UIManager.register_buttons(self)
	AudioManager.play_music("MenuPrincipal")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_POINTING_HAND)


# -- Acciones --

# Cargar Partida
func _on_cargar_partida_pressed() -> void:
	get_tree().change_scene_to_file("res://Menús/escenas/cargar_partidas/cargar_partida.tscn")
	AudioManager.play("menu_principal_click")

# Nueva Partida
func _on_nueva_partida_pressed() -> void:
	get_tree().change_scene_to_file("res://Menús/escenas/nuevas_partidas/nueva_partida.tscn")
	AudioManager.play("menu_principal_click")

# Ajustes
func _on_ajustes_pressed() -> void:
	get_tree().change_scene_to_file("res://Menús/escenas/ajustes/ajustes_screen.tscn")
	AudioManager.play("menu_principal_click")

# Salir
func _on_salir_pressed() -> void:
	get_tree().quit()


# -- Mox Playground --

var shaking := false

func _on_mox_nose_pressed() -> void:
	if shaking:
		return

	shaking = true
	AudioManager.play("MadMox", 0.2)
	sprite.scale = Vector2(3.5, 3.5)
	await get_tree().create_timer(0.08).timeout
	sprite.scale = Vector2(3, 3)

	var original_pos = sprite.position
	sprite.modulate = Color(1, 0.4, 0.4)

	for i in 6:
		sprite.position = original_pos + Vector2(
			randf_range(-3, 3),
			randf_range(-3, 3)
		)
		await get_tree().create_timer(0.03).timeout

	sprite.position = original_pos
	sprite.modulate = Color(1, 1, 1)

	shaking = false


func _on_nombre_pressed() -> void:
	pass # Replace with function body.
