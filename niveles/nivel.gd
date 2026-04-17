extends Node2D

@onready var musica = $AudioStreamPlayer
@onready var noTimeSound = $NoTimeSound
var musica_acelerada = false

func _ready():
	musica.pitch_scale = 1

func _process (delta):
	if GameState.tiempo_restante <= 21 and not musica_acelerada: # El and not musica_acelerada es para que no asigne el valor constantemente
		musica.stop()
		noTimeSound.play()
		musica_acelerada = true
		await get_tree().create_timer(2.3).timeout
		musica.pitch_scale = 1.25
		musica.play()
		
	
