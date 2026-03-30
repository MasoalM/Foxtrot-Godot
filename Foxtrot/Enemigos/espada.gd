extends Area2D

@export var damage := 1
@export var duration := 0.25

var timer := 0.0

var start_rotation := 0.0
var end_rotation := 0.0

var direction = 1

func set_direction(dir):
	direction = dir

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
	
	var t = timer / duration
	t = clamp(t, 0.0, 1.0)
	
	rotation = lerp(start_rotation, end_rotation, t)
	
	if t >= 1.0:
		queue_free()
