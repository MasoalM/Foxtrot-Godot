extends Node2D

@onready var label = $Label

var velocity = Vector2(0, -40)
var lifetime = 1.0

func setup(texto):
	label.text = texto

func _process(delta):
	position += velocity * delta

	lifetime -= delta

	# fade
	modulate.a = lifetime

	if lifetime <= 0:
		queue_free()
