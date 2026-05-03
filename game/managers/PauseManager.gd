extends Node

var pause_menu

func _ready() -> void:
	var scene = preload("res://Menús/escenas/pause_screen/pause_screen.tscn")
	pause_menu = scene.instantiate()
	
	get_tree().root.add_child.call_deferred(pause_menu)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause_screen") and can_pause():
		handle_pause()

# -- Pause Menu Handler --

func can_pause() -> bool:
	return get_tree().current_scene != null and get_tree().current_scene.is_in_group("Level")

func handle_pause():
	if get_tree().paused:
		resume()
	else:
		pause()

func pause():
	get_tree().paused = true
	pause_menu.show_menu()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume():
	get_tree().paused = false
	pause_menu.hide_menu()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
