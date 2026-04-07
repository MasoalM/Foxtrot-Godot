extends TextureButton

const SLOT_DEFAULT_TEXTURE = preload("res://Menús/assets/Ranura.png")
const SLOT_SELECTED_TEXTURE = preload("res://Menús/assets/Ranura Seleccionada.png")

var selected_slot = null
var selected_button = null

func _ready() -> void:
	UIManager.register_button(self)

	selected_slot = null
	update_play_button()

func _on_slot_pressed(button, slot_id) -> void:
	var info = $"../../Menú/Información"
	var selected_label = $"../../Menú/Información/Info/Partida seleccionada"
	
	if selected_button != null:
		selected_button.texture_normal = SLOT_DEFAULT_TEXTURE
		
	selected_slot = slot_id
	selected_button = button
	selected_button.texture_normal = SLOT_SELECTED_TEXTURE
	selected_label.text = "RANURA DE PARTIDA " + str(slot_id)
	
	info.visible = true
	AudioManager.play("click")
	update_play_button()

func _on_jugar_pressed():
	if selected_slot == null:
		return
	
	var partidas = $"../../Menú/Menú Partidas"
	var informacion = $"../../Menú/Información"
	var botones = $".."
	var confirmar = $"../../Menú Confirmar"
	
	partidas.visible = false
	informacion.visible = false
	botones.visible = false
	confirmar.visible = true
	
	AudioManager.play("click")
	
	print("Cargar partida: ", selected_slot)

func update_play_button():
	var play_button = $"."
	
	if selected_slot == null:
		play_button.disabled = true
		play_button.mouse_default_cursor_shape = CURSOR_ARROW
	else:
		play_button.disabled = false
		play_button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
