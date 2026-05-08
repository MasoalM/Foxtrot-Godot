extends Control

func _ready() -> void:
	UIManager.register_buttons(self)
	AudioManager.play_music("MenuPrincipal")
