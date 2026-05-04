extends Area2D

@export var damage := 1
@export var duration := 0.25
@onready var sprite = $Sprite2D

var timer := 0.0

var start_rotation := 0.0
var end_rotation := 0.0

var direction = 1

func set_direction(dir):
	direction = dir

	if direction == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _ready():
	add_to_group("Enemigos")
	
	if direction == 1:
		start_rotation = deg_to_rad(0)
		end_rotation = deg_to_rad(180)
	else:
		start_rotation = deg_to_rad(0)
		end_rotation = deg_to_rad(-180)

func _physics_process(delta):
	timer += delta
	
	var t = clamp(timer / duration, 0.0, 1.0)
	
	var angle_diff = end_rotation - start_rotation

	# Normalizar entre -PI y PI
	angle_diff = wrapf(angle_diff, -PI, PI)

	# FORZAR dirección según el lado
	if direction == 1 and angle_diff < 0:
		angle_diff += TAU
	elif direction == -1 and angle_diff > 0:
		angle_diff -= TAU

	rotation = start_rotation + angle_diff * t
	
	if t >= 1.0:
		queue_free()
