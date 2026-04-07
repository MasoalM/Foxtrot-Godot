extends TextureRect

@onready var musica_label = $"Música Label"
@onready var efectos_label = $"Efectos Label"

func _on_música_value_changed(value: int) -> void:
	musica_label.text = str(value) + "%"

func _on_efectos_value_changed(value: int) -> void:
	efectos_label.text = str(value) + "%"
