extends Node

enum State {
	DISABLED,
	NORMAL,
	HOVER,
	PRESSED
}

func register_button(button):
	if not button is BaseButton:
		return
	
	if button.has_meta("ui_registered"):
		return
	
	button.set_meta("ui_registered", true)
	button.set_meta("state", State.NORMAL)
	
	button.pivot_offset = button.size / 2
	
	button.mouse_entered.connect(_on_hover.bind(button))
	button.mouse_exited.connect(_on_exit.bind(button))
	button.button_down.connect(_on_down.bind(button))
	button.button_up.connect(_on_up.bind(button))

func register_buttons(node: Node):
	for child in node.get_children():
		if child is TextureButton:
			register_button(child)
		
		register_buttons(child)


# -- Funciones

func _on_hover(button):
	if button.disabled:
		return
	
	AudioManager.play_random_pitch("hover_button", 0.0, 0.2)
	set_state(button, State.HOVER)

func _on_exit(button):
	if button.disabled:
		return
	
	set_state(button, State.NORMAL)

func _on_down(button):
	if button.disabled:
		return
	
	set_state(button, State.PRESSED)

func _on_up(button):
	if button.disabled:
		return
	
	if button.is_hovered():
		set_state(button, State.HOVER)
	else:
		set_state(button, State.NORMAL)


# -- Estados

func set_state(button, state):
	var current_state = button.get_meta("state")
	
	if current_state == state:
		return
	
	button.set_meta("state", state)
	
	var target_scale
	match state:
		State.NORMAL:
			target_scale = Vector2(1, 1)
		State.HOVER:
			target_scale = Vector2(1.03, 1.03)
		State.PRESSED:
			target_scale = Vector2(0.97, 0.97)
	
	animate(button, target_scale)


# -- Animaciones

func animate(button, target_scale):
	if button.has_meta("tween"):
		var old = button.get_meta("tween")
		if old:
			old.kill()
	
	var tween = create_tween()
	button.set_meta("tween", tween)
	
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", target_scale, 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
