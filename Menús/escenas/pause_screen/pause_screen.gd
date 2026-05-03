extends CanvasLayer

var pointer_texture = preload("res://Sprites/Pointer.png")

func _ready():
	UIManager.register_buttons(self)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS
		
	visible = false
	
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(pointer_texture, Input.CURSOR_POINTING_HAND)

# -- Pause Menu Handler --

func show_menu():
	visible = true

func hide_menu():
	visible = false

# -- Botones --

func _on_reanudar_pressed() -> void:
	PauseManager.resume()
	AudioManager.play("click")
