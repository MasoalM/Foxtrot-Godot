extends Area2D

@export var speed := 250.0
@export var turn_speed := 2.0
@export var lifetime := 5.0

var velocity := Vector2.ZERO
var target: Node2D = null
var shooter: Node2D = null   # MUY IMPORTANTE

func _ready():
	monitoring = false
	await get_tree().process_frame
	monitoring = true

func _physics_process(delta):
	

	# --- VALIDACIÓN FUERTE ---
	if target == null:
		
		position += velocity * delta
		return

	if not is_instance_valid(target):
	
		position += velocity * delta
		return

	# --- HOMING ---
	var desired_direction = (target.global_position - global_position).normalized()
	var current_direction = velocity.normalized()
	
	var new_direction = current_direction.lerp(desired_direction, turn_speed * delta).normalized()
	velocity = new_direction * speed

	# --- MOVIMIENTO ---
	position += velocity * delta
	
	# --- ROTACIÓN ---
	if velocity.length() > 0.1:
		rotation = velocity.angle()

func _on_body_entered(body):
	if body == shooter:
		return
	
	if body.is_in_group("player"):
		print("HIT PLAYER")
	
	queue_free()
	
func set_direction_from_target(target_node):
	if not is_instance_valid(target_node):
		return
	
	var dir = sign(target_node.global_position.x - global_position.x)
	
	# evitar 0
	if dir == 0:
		dir = 1
	
	velocity = Vector2(dir, 0) * speed	


func set_target(t):
	target = t

func set_shooter(s):
	shooter = s
	

	
