extends TextureRect

@onready var musica_slider = $"Música"
@onready var musica_label = $"Música Label"
@onready var efectos_slider = $"Efectos"
@onready var efectos_label = $"Efectos Label"

func _ready() -> void:
	var musica_vol = SettingsManager.get_setting("audio", "musica")
	var efectos_vol = SettingsManager.get_setting("audio", "efectos")
	
	var musica_final_vol = int(musica_vol * 100)
	musica_label.text = str(musica_final_vol) + "%"
	musica_slider.value = musica_final_vol
	
	var efectos_final_vol = int(efectos_vol * 100)
	efectos_label.text = str(efectos_final_vol) + "%"
	efectos_slider.value = efectos_final_vol

func _on_música_value_changed(value: float) -> void:
	musica_label.text = str(int(value)) + "%"
	
	var normalized = value / 100
	SettingsManager.save_setting("audio", "musica", normalized)
	SettingsManager.apply_settings()

func _on_efectos_value_changed(value: float) -> void:
	efectos_label.text = str(int(value)) + "%"
	
	var normalized = value / 100
	SettingsManager.save_setting("audio", "efectos", normalized)
	SettingsManager.apply_settings()
