extends HBoxContainer

func _ready():
	for child in get_children():
		if child is TextureButton:
			UIManager.register_button(child)


func _on_sí_pressed() -> void:
	AudioManager.play("click")

func _on_no_pressed() -> void:
	var partidas = $"../../../Menú/Menú Partidas"
	var informacion = $"../../../Menú/Información"
	var botones = $"../../../Botones"
	var confirmar = $"../.."
	
	partidas.visible = true
	informacion.visible = true
	botones.visible = true
	confirmar.visible = false
	
	AudioManager.play("back_click")
	
