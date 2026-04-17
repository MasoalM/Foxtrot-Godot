extends Node2D

@onready var musica = $AudioStreamPlayer
var musica_acelerada = false

func _ready():
	musica.pitch_scale = 1

func _process (delta):
	if GameState.tiempo_restante <= 10:
		musica.pitch_scale = 1.25
	
