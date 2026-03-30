extends CharacterBody2D
@onready var hitbox = $hitboxAtaque
@onready var espada_idle = $EspadaIdle
@onready var espada_sprite = $EspadaIdle/sword

var speed = 120
var player
var start_position
var detect_distance = 600
var patrol_distance = 75
var chasing = false
var chase_timer = 0.0
var chase_duration = 2.0
var attack_distance = 50
var attack_cooldown = 1.0
var attack_timer = 0.0

var gravity = 900
var jump_force = -450
var knockback_force = 300
var knockback_timer = 1.5
var knockback_duration = 0.2
var knockback_up_force = -200
var in_knockback = false

var detect_distance_x = 600 
var detect_distance_y = 80 

var patrol_direction = 1

var patrol_wait_time := 0.0
var patrol_wait_duration = randf_range(1.0, 3.0)
var patrol_move_duration = randf_range(2.0, 5.0)

var is_waiting := false

var stuck_timer = 0.0
var last_x = 0.0
var stuck_time_limit = 0.5
var lives
var espada_scene = preload("res://Enemigos//Espada.tscn")
@onready var ray = $RayCast2D



func _ready():
	get_tree().debug_collisions_hint = true
	
	add_to_group("Enemigos")
	player = get_tree().get_first_node_in_group("player")
	print("PLAYER ES:", player)
	hitbox.area_entered.connect(_on_area_2d_area_entered)
	start_position = global_position
	last_x = global_position.x
	lives=2
	patrol_wait_time = patrol_move_duration


func _physics_process(delta):
	attack_timer -= delta
	
	# --- KNOCKBACK ---
	if knockback_timer > 0:
		knockback_timer -= delta
	else:
		in_knockback = false

	# --- GRAVEDAD ---
	if !is_on_floor():
		velocity.y += gravity * delta

	# --- DETECCIÓN PLAYER ---
	if player:
		var distance = global_position.distance_to(player.global_position)

		if can_see_player() and distance < detect_distance:
			chasing = true
			chase_timer = chase_duration

	# --- CHASE ---
	if chasing:
		chase_timer -= delta

		if is_instance_valid(player):
			var distance_x = abs(player.global_position.x - global_position.x)

			if not in_knockback:
				if distance_x < attack_distance:
					velocity.x = 0
					if attack_timer <= 0:
						attack()
						attack_timer = attack_cooldown
				else:
					if player.global_position.x > global_position.x:
						velocity.x = speed
					else:
						velocity.x = -speed

			if chase_timer <= 0:
				chasing = false

	# --- PATROL ---
	else:
		patrol_wait_time -= delta

		if is_waiting:
			if not in_knockback:
				velocity.x = 0

			if patrol_wait_time <= 0:
				is_waiting = false
				patrol_wait_time = patrol_move_duration

		else:
			if not in_knockback:
				velocity.x = patrol_direction * speed

			if global_position.x > start_position.x + patrol_distance:
				patrol_direction = -1

			if global_position.x < start_position.x - patrol_distance:
				patrol_direction = 1

			if patrol_wait_time <= 0:
				is_waiting = true
				patrol_wait_time = patrol_wait_duration

	# --- FLIP GLOBAL + ESPADA ---
	var flip = false

	if chasing and player:
		flip = player.global_position.x < global_position.x
	elif velocity.x != 0:
		flip = velocity.x < 0

	# Flip del lobo
	$Sprite2D.flip_h = flip

	# Flip de la espada (sprite interno)
	espada_sprite.flip_h = flip

	# 🔥 POSICIÓN + ROTACIÓN EXACTA QUE PEDISTE
	if flip:
		# IZQUIERDA
		espada_idle.position.x = -40
		espada_idle.rotation = deg_to_rad(-30)
	else:
		# DERECHA
		espada_idle.position.x = 35
		espada_idle.rotation = deg_to_rad(30)

	# --- ANTI-STUCK ---
	if abs(global_position.x - last_x) < 1 and is_on_floor() and velocity.x != 0:
		stuck_timer += delta
	else:
		stuck_timer = 0

	if stuck_timer > stuck_time_limit:
		velocity.y = jump_force
		stuck_timer = 0

	last_x = global_position.x

	move_and_slide()
	
func can_see_player():
	if player == null or ray == null:
		return false

	var origin = global_position + Vector2(0, -20)
	var target = player.global_position + Vector2(0, -20)

	var direction = target - origin
	ray.global_position = origin
	ray.target_position = direction.normalized() * 800
	ray.force_raycast_update()

	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider.is_in_group("player"):
			return true

		
		return false

	
	return false
	
	
func attack():
	if !is_instance_valid(player):
		return

	var espada = espada_scene.instantiate()

	var offset_x = 20
	var dir = 1

	# Detectar dirección del jugador
	if player.global_position.x < global_position.x:
		offset_x = -20
		dir = -1
	
	var pos = global_position + Vector2(offset_x, 20)

	if is_instance_valid(espada_idle):
		espada_idle.visible = false

	# Configurar espada de ataque
	espada.global_position = pos
	espada.scale.x = dir

	if espada.has_method("set_direction"):
		espada.set_direction(dir)

	get_parent().add_child(espada)

	# --- HITBOX ---
	hitbox.monitoring = true

	var shape_node = hitbox.get_node("CollisionShape2D")
	var shape = shape_node.shape as CapsuleShape2D

	var original_radius = shape.radius
	var original_height = shape.height

	# Agrandar hitbox
	shape.radius = original_radius * 2

	# Mover hitbox según dirección
	if dir == -1:
		shape_node.position.x = -original_radius
	else:
		shape_node.position.x = original_radius

	await get_tree().create_timer(0.25).timeout

	# Restaurar hitbox
	shape.radius = original_radius
	shape.height = original_height
	shape_node.position.x = 0
	


	if is_instance_valid(espada_idle):
		espada_idle.visible = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.get_groups())
	if area.is_in_group("ProyectilAliado"):
		print("funciono")
		
		if area.has_method("morir"):
			area.morir()
		print("funciono2")
		lives -= 1
		var direction = sign(global_position.x - area.global_position.x)
		
		velocity.x = direction * knockback_force

		if is_on_floor():
			velocity.y = knockback_up_force

		knockback_timer = knockback_duration
		in_knockback = true
		
		
		if lives == 0:
			print("liberado")
			queue_free()
