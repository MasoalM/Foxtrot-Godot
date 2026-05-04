extends Control


# -- Entry Control --

@onready var partidas = $"Fondo/Menú/Menú Partidas"
@onready var informacion = $"Fondo/Menú/Información"
@onready var botones = $Fondo/Botones
@onready var confirmar = $"Fondo/Menú Confirmar"
@onready var ninguna_partida = $"Fondo/Menú Ninguna Partida"


# -- Variables Cargar Partidas --

var selected_slot = null
var selected_button = null


# -- Cargar Partida Handling --

func _ready() -> void:
	UIManager.register_buttons(self)
	
	# Saltar aviso de ninguna partida creada
	var exists_any_save: bool = SaveManager._exists_any()
	if not exists_any_save:
		partidas.visible = false
		botones.visible = false
		ninguna_partida.visible = true
		return
	
	# Cargar textura inicial
	var slots = $"Fondo/Menú/Menú Partidas/Partidas"
	for i in slots.get_children():
		var slot := i.name
		
		if SaveManager._exists(slot):
			var slot_asset = "res://Menús/assets/slots/%s.png" % slot
			var slot_button: TextureButton = get_node("Fondo/Menú/Menú Partidas/Partidas/%s" % slot)
			
			slot_button.texture_normal = load(slot_asset)
	
	# Actualizar estado inicial del botón jugar
	update_play_button()


# -- Button Actions --

func _on_slot_pressed(button, slot_id) -> void:
	var selected_label = $"Fondo/Menú/Información/InfoCargar/Partida seleccionada"
	var play_time = $"Fondo/Menú/Información/InfoCargar/Tiempo de juego"
	var last_time_played = $"Fondo/Menú/Información/InfoCargar/Última vez"
	var lives = $"Fondo/Menú/Información/InfoCargar/Vidas"
	var max_level = $"Fondo/Menú/Información/InfoCargar/Nivel alcanzado"
	var collectibles = $"Fondo/Menú/Información/InfoCargar/Coleccionables"
	
	if SaveManager._exists(slot_id):
		var slot_save: SaveData = ResourceLoader.load(SaveManager._get_path(slot_id))
		
		selected_label.text = "RANURA DE PARTIDA: " + slot_save.title
		SaveManager.set_info(play_time, Utils.format_play_time(slot_save.play_time))
		SaveManager.set_info(last_time_played, Utils.format_time(slot_save.last_time_played))
		SaveManager.set_info(lives, str(slot_save.lives))
		SaveManager.set_info(max_level, str(slot_save.max_level))
		SaveManager.set_info(collectibles, str(slot_save.get_total_collected()))
	else:
		selected_label.text = "NUEVA PARTIDA - SLOT " + str(slot_id)
		SaveManager.set_info(play_time, "N/A")
		SaveManager.set_info(last_time_played, "N/A")
		SaveManager.set_info(lives, "N/A")
		SaveManager.set_info(max_level, "N/A")
		SaveManager.set_info(collectibles, "N/A")
	
	if selected_button:
		selected_button.texture_normal = SaveManager.get_slot_texture(selected_slot, false)
	
	selected_slot = slot_id
	selected_button = button
	selected_button.texture_normal = SaveManager.get_slot_texture(selected_slot, true)
	
	informacion.visible = true
	update_play_button()
	
	AudioManager.play("click")

func _on_jugar_pressed():
	SaveManager.load_game(selected_slot)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	handle_ontop_menu(false)
	confirmar.visible = true
	
	get_tree().change_scene_to_file("res://niveles/level_selector.tscn")
	
	AudioManager.play("click")
	print("Cargar partida: ", selected_slot)

func _on_nueva_partida_pressed():
	get_tree().change_scene_to_file("res://Menús/escenas/nuevas_partidas/nueva_partida.tscn")
	AudioManager.play("click")


# -- Update Buttons --

func update_play_button():
	var play_button : TextureButton = $Fondo/Botones/Jugar
	
	if selected_slot == null or not SaveManager._exists(selected_slot):
		play_button.disabled = true
		play_button.mouse_default_cursor_shape = CURSOR_ARROW
	else:
		play_button.disabled = false
		play_button.mouse_default_cursor_shape = CURSOR_POINTING_HAND


# -- Handle Menus Visibilities --

func handle_ontop_menu(visibility: bool):
	partidas.visible = visibility
	informacion.visible = visibility
	botones.visible = visibility


# -- Confirmations --

func _on_sí_pressed() -> void:
	SaveManager.load_game(selected_slot)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene_to_file("res://niveles/level_selector.tscn")
	
	AudioManager.play("click")

func _on_no_pressed() -> void:
	handle_ontop_menu(true)
	confirmar.visible = false
	
	AudioManager.play("back_click")
