extends Area2D

@export var fuerza = 1200

@export var amplitud = 50      # Qué tanto sube y baja
@export var velocidad = 2.0    # Qué tan rápido oscila

var posicion_inicial
var tiempo = 0.0

func _ready():
	posicion_inicial = global_position

func _process(delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.velocity.y -= fuerza * delta
