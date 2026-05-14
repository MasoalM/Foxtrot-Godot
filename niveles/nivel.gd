extends Node2D

@onready var musica = $AudioStreamPlayer
var noTimeSound: AudioStreamPlayer

var musica_acelerada = false

func _ready():
	add_to_group("Gameplay")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var scene = get_tree().current_scene.scene_file_path
	if scene != "res://niveles/level_selector.tscn":
		noTimeSound = AudioManager.get_player("NoTime")
		noTimeSound.volume_db = -2.0
		noTimeSound.pitch_scale = 0.75
	
	musica.pitch_scale = 1

func _process(_delta: float):
	if GameState.tiempo_restante <= 61 and not musica_acelerada: # El and not musica_acelerada es para que no asigne el valor constantemente
		if noTimeSound:
			noTimeSound.play()
			
		musica.stop()
		musica_acelerada = true
		await get_tree().create_timer(2.3).timeout
		musica.pitch_scale = 1.25
		musica.play()
		
	
