extends TextureRect

@onready var musica_slider = $"Música"
@onready var musica_label = $"Música Label"

@onready var efectos_slider = $"Efectos"
@onready var efectos_label = $"Efectos Label"

func _ready() -> void:
	refresh()

func refresh():
	var data = SettingsManager.data
	
	var musica_vol: int = int(data.musica * 100)
	musica_slider.value = musica_vol
	musica_label.text = str(musica_vol) + "%"
	
	var efectos_vol: int = int(data.efectos * 100)
	efectos_slider.value = efectos_vol
	efectos_label.text = str(efectos_vol) + "%"


# -- Sliders --

func _on_música_value_changed(value: float) -> void:
	var normalized = value / 100
	
	musica_label.text = str(int(value)) + "%"
	
	SettingsManager.data.musica = normalized
	SettingsManager.apply_settings()
	SettingsManager.save_from_data()

func _on_efectos_value_changed(value: float) -> void:
	var normalized = value / 100
	
	efectos_label.text = str(int(value)) + "%"
	
	SettingsManager.data.efectos = normalized
	SettingsManager.apply_settings()
	SettingsManager.save_from_data()
