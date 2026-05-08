extends Control


# -- Entry Control --

@onready var partidas = $"Fondo/Menú/Menú Partidas"

@onready var informacion = $"Fondo/Menú/Información"
@onready var selected_label: Label = $"Fondo/Menú/Información/InfoCargar/Partida seleccionada"
@onready var game_title: LineEdit = $"Fondo/Menú/Información/InfoCargar/Introducir nombre"

@onready var botones = $Fondo/Botones
@onready var confirmar = $"Fondo/Menú Confirmar"

@onready var crear_button: TextureButton = $"Fondo/Botones/Botones Cargar/Crear"
@onready var eliminar_button: TextureButton = $"Fondo/Botones/Botones Cargar/Eliminar"

@onready var confirmar_eliminar = $"Fondo/Menú Eliminar/Confirmar Eliminar"
@onready var reconfirmar_eliminar = $"Fondo/Menú Eliminar/Reconfirmar Eliminar"
@onready var eliminado = $"Fondo/Menú Eliminar/Eliminado"


# -- Variables Nuevas Partidas --

var selected_slot = null
var selected_button = null


# -- Nueva Partida Handling --

func _ready() -> void:
	UIManager.register_buttons(self)
	
	# Cargar textura inicial
	var slots = $"Fondo/Menú/Menú Partidas/Partidas"
	for i in slots.get_children():
		var slot := i.name
		
		if SaveManager._exists(slot):
			var slot_asset = "res://Menús/assets/slots/%s.png" % slot
			var slot_button: TextureButton = get_node("Fondo/Menú/Menú Partidas/Partidas/%s" % slot)
			
			slot_button.texture_normal = load(slot_asset)
	
	# Actualizar estado inicial de botones crear y eliminar
	update_crear_button()
	update_eliminar_button()


# -- Button Actions --

func _on_slot_pressed(button: TextureButton, slot_id: String) -> void:
	if SaveManager._exists(slot_id):
		var slot_save: SaveData = ResourceLoader.load(SaveManager._get_path(slot_id))
		
		game_title.editable = false
		game_title.text = slot_save.title
		selected_label.text = "EL SLOT " + str(slot_id) + " YA ESTÁ EN USO"
	else:
		game_title.editable = true
		game_title.text = ""
		selected_label.text = "NUEVA PARTIDA - SLOT " + str(slot_id)
	
	if selected_button:
		selected_button.texture_normal = SaveManager.get_slot_texture(selected_slot, false)
	
	selected_slot = slot_id
	selected_button = button
	selected_button.texture_normal = SaveManager.get_slot_texture(selected_slot, true)
	
	informacion.visible = true
	update_crear_button()
	update_eliminar_button()
	
	AudioManager.play("click")

func _on_crear_pressed():
	handle_ontop_menu(false)
	confirmar.visible = true
	
	AudioManager.play("click")

func _on_eliminar_pressed():
	handle_ontop_menu(false)
	confirmar_eliminar.visible = true
	
	AudioManager.play("click")


# -- Writing Actions --

func _on_introducir_nombre_text_changed(text: String) -> void:
	var max_chars = $"Fondo/Menú/Información/InfoCargar/Introducir nombre/Carácteres máximos"
	
	if text.length() > 24:
		max_chars.visible = true
		crear_button.disabled = true
	else:
		max_chars.visible = false
		crear_button.disabled = false


# -- Update Buttons --

func update_crear_button():
	if selected_slot == null or SaveManager._exists(selected_slot):
		crear_button.disabled = true
		crear_button.mouse_default_cursor_shape = TextureButton.CURSOR_ARROW
	else:
		crear_button.disabled = false
		crear_button.mouse_default_cursor_shape = TextureButton.CURSOR_POINTING_HAND

func update_eliminar_button():
	if selected_slot != null and SaveManager._exists(selected_slot):
		eliminar_button.disabled = false
		eliminar_button.mouse_default_cursor_shape = TextureButton.CURSOR_POINTING_HAND
	else:
		eliminar_button.disabled = true
		eliminar_button.mouse_default_cursor_shape = TextureButton.CURSOR_ARROW


# -- Handle Menus Visibilities --

func handle_ontop_menu(visibility: bool):
	partidas.visible = visibility
	informacion.visible = visibility
	botones.visible = visibility


# -- Confirmations --

func _on_sí_pressed(action: bool) -> void:
	if action:
		SaveManager.create_game(selected_slot, game_title.text)
		SaveManager.save_game()
		
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		get_tree().change_scene_to_file("res://niveles/level_selector.tscn")
	else:
		confirmar_eliminar.visible = false
		reconfirmar_eliminar.visible = true
	
	AudioManager.play("click")

func _on_no_pressed() -> void:
	handle_ontop_menu(true)
	confirmar.visible = false
	confirmar_eliminar.visible = false
	
	AudioManager.play("back_click")

func _on_continuar_pressed() -> void:
	SaveManager.load_game(selected_slot)
	SaveManager.delete_game()
	
	reconfirmar_eliminar.visible = false
	eliminado.visible = true
	
	AudioManager.play("click")

func _on_atras_pressed() -> void:
	handle_ontop_menu(true)
	reconfirmar_eliminar.visible = false
	
	AudioManager.play("back_click")

func _on_aceptar_pressed() -> void:
	eliminado.visible = false
	get_tree().reload_current_scene()
	
	AudioManager.play("click")
