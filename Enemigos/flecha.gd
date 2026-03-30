extends Area2D

@export var speed := 400
@export var gravity_force := 900 

var velocity = Vector2.ZERO
var shooter = null

func _ready():
	add_to_group("Enemigos")

func _physics_process(delta):
	# aplicar gravedad
	velocity.y += gravity_force * delta
	
	# mover proyectil
	position += velocity * delta
	
	# rotar hacia la dirección del movimiento
	rotation = velocity.angle() + deg_to_rad(90)


func shoot_to_target(target_pos):
	var time = clamp(global_position.distance_to(target_pos) / 300.0, 0.5, 1.5)

	var displacement = target_pos - global_position

	velocity.x = displacement.x / time
	velocity.y = (displacement.y / time) - (0.5 * gravity_force * time)

	print("VEL:", velocity)


func _on_body_entered(body):
	if body == shooter:
		return

	if body.is_in_group("player"):
		print("Jugador golpeado")

	queue_free()
