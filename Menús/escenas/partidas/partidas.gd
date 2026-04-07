extends HBoxContainer

func _ready() -> void:
	for child in get_children():
		if child is TextureButton:
			UIManager.register_button(child)
