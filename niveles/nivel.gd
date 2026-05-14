extends Node2D

@onready var musica = $AudioStreamPlayer

var musica_acelerada = false

func _ready():
	add_to_group("Gameplay")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float):
	if GameState.tiempo_restante <= 61 and not musica_acelerada: # El and not musica_acelerada es para que no asigne el valor constantemente
		var scene = get_tree().current_scene.scene_file_path
		if scene != "res://niveles/level_selector.tscn":
			AudioManager.play("NoTime", -2.0, 0.75, global_position)
			
		musica.stop()
		musica_acelerada = true
		await get_tree().create_timer(2.3).timeout
		musica.pitch_scale = 1.25
		musica.play()
		
	
