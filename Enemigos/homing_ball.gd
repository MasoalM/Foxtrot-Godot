extends Area2D

@export var speed := 250.0
@export var turn_speed := 2.0
@export var lifetime := 5.0
var velocity := Vector2.ZERO
var target: Node2D = null
var shooter: Node2D = null
var _lifetime_timer := 0.0

func _ready():
	add_to_group("EnemyBall")
	collision_layer = 4   # capa propia de la bola
	collision_mask = 2    # detecta al jugador (capa 2)
	monitoring = false
	await get_tree().process_frame
	monitoring = true

func _physics_process(delta):
	_lifetime_timer += delta
	if _lifetime_timer >= lifetime:
		queue_free()
		return

	if target == null or not is_instance_valid(target):
		position += velocity * delta
		return

	var desired_direction = (target.global_position - global_position).normalized()
	var current_direction = velocity.normalized()
	var new_direction = current_direction.lerp(desired_direction, turn_speed * delta).normalized()
	velocity = new_direction * speed
	position += velocity * delta

	if velocity.length() > 0.1:
		rotation = velocity.angle()

func _on_body_entered(body):
	if body == shooter:
		return
	if body.is_in_group("player"):
		body._dañar()
		queue_free()

func set_direction_from_target(target_node):
	if not is_instance_valid(target_node):
		return
	var dir = sign(target_node.global_position.x - global_position.x)
	if dir == 0:
		dir = 1
	velocity = Vector2(dir, 0) * speed

func set_target(t):
	target = t

func set_shooter(s):
	shooter = s
