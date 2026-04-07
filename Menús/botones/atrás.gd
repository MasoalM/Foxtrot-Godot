extends TextureButton

func _ready() -> void:
	UIManager.register_button(self)

func _on_pressed() -> void:
	AudioManager.play("back_click")
	get_tree().change_scene_to_file("res://Menús/escenas/principal.tscn")
