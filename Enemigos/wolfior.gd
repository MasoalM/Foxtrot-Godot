extends CharacterBody2D

@onready var hitbox = $hitboxAtaque
@onready var espada_idle = $EspadaIdle
@onready var espada_sprite = $EspadaIdle/sword
@onready var animated_sprite = $AnimatedSprite2D
@onready var aullidoMuerte = $AudioStreamPlayer2DDeath
@onready var madSound = $AudioStreamPlayer2DMad
@onready var jumpSound = $AudioStreamPlayer2DJump
@onready var swordHitSound = $AudioStreamPlayer2DSwordHit
@onready var hurtSound = $AudioStreamPlayer2DHurt
@onready var freezeSound = $AudioStreamPlayer2DFreeze

var popup_scene = preload("res://personaje/PointPopup.tscn")

@export var speed = 120
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
var eshielo = false

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
@export var lives = 2
var espada_scene = preload("res://Enemigos//Espada.tscn")

const HURT_LIVES = 1
const DEATH_LIVES = 0


var base_radius
var base_height

#congelar
var congelado = false
var freeze_timer = 0.0

@onready var ray = $RayCast2D



func _ready():
	var shape = hitbox.get_node("CollisionShape2D").shape as CapsuleShape2D

	base_radius = shape.radius
	base_height = shape.height
	add_to_group("Enemigos")
	player = get_tree().get_first_node_in_group("player")
	start_position = global_position
	last_x = global_position.x
	patrol_wait_time = patrol_move_duration
	# Hacer el shape único para esta instancia
	var shape_node = hitbox.get_node("CollisionShape2D")
	shape_node.shape = shape_node.shape.duplicate()


func _physics_process(delta):
	
	if congelado:
		freeze_timer -= delta
	
		if freeze_timer <= 0:
			congelado = false
			animated_sprite.modulate = Color(1, 1, 1)
		
		return

	# GRAVEDAD SIEMPRE ACTIVA
	if !is_on_floor():
		velocity.y += gravity * delta

	if lives > 0:
		attack_timer -= delta
		
		# --- KNOCKBACK ---
		if knockback_timer > 0:
			knockback_timer -= delta
		else:
			in_knockback = false

		# --- DETECCIÓN PLAYER ---
		if player:
			var distance = global_position.distance_to(player.global_position)

			if can_see_player() and distance < detect_distance:
				if !chasing:
					madSound.play()
					
				chasing = true
				chase_timer = chase_duration

		# --- CHASE ---
		if chasing:
			if is_on_floor():
				if lives == HURT_LIVES:
					animated_sprite.play("hurtChase")
				else:
					animated_sprite.play("chase")
					
			chase_timer -= delta

			if is_instance_valid(player):
				var distance_x = abs(player.global_position.x - global_position.x)

				if not in_knockback:
					if distance_x < attack_distance:
						velocity.x = 0
						if attack_timer <= 0:
							attack()
							swordHitSound.play()
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
				if is_on_floor():
					if lives == HURT_LIVES:
						animated_sprite.play("hurtIdle")
					else: 
						animated_sprite.play("idle")

				if not in_knockback:
					velocity.x = 0

				if patrol_wait_time <= 0:
					is_waiting = false
					if is_on_floor():
						if lives == HURT_LIVES:
							animated_sprite.play("hurtWalk")
						else:
							animated_sprite.play("walk")
					
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

		$AnimatedSprite2D.flip_h = flip
		espada_sprite.flip_h = flip

		if flip:
			espada_idle.position.x = -40
			espada_idle.rotation = deg_to_rad(-30)
		else:
			espada_idle.position.x = 35
			espada_idle.rotation = deg_to_rad(30)

		# --- ANTI-STUCK ---
		if abs(global_position.x - last_x) < 1 and is_on_floor() and velocity.x != 0:
			stuck_timer += delta
		else:
			stuck_timer = 0

		if (stuck_timer > stuck_time_limit):
			jumpSound.play()
			
			if lives == HURT_LIVES:
				animated_sprite.play("hurtJump")
			else:
				animated_sprite.play("jump")
				
			velocity.y = jump_force
			stuck_timer = 0

		last_x = global_position.x

	else:
	# 
		velocity.x = 0
		
		if is_on_floor():
			set_physics_process(false)  # lo congela completamente

	# SIEMPRE se aplica movimiento
	move_and_slide()
func can_see_player():
	if lives > 0:
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
	return false
	
	
func attack():
	if lives > 0:
		if !is_instance_valid(player):
			return

		var espada = espada_scene.instantiate()

		var offset_x = 20
		var dir = 1

		if player.global_position.x < global_position.x:
			offset_x = -20
			dir = -1
		
		if is_instance_valid(espada_idle):
			espada_idle.visible = false

		# Añadir como hijo del enemigo
		add_child(espada)

		# Posición LOCAL (ahora sí sigue al enemigo)
		espada.position = Vector2(offset_x, 20)

		# Dirección
		if espada.has_method("set_direction"):
			espada.set_direction(dir)

		# --- HITBOX ---
		hitbox.monitoring = true

		var shape_node = hitbox.get_node("CollisionShape2D")
		var shape = shape_node.shape as CapsuleShape2D

		var original_radius = shape.radius
		var original_height = shape.height

		shape.radius = original_radius * 2

		if dir == -1:
			shape_node.position.x = -original_radius
		else:
			shape_node.position.x = original_radius

		await get_tree().create_timer(0.25).timeout

		shape.radius = original_radius
		shape.height = original_height
		shape_node.position.x = 0

		if is_instance_valid(espada_idle):
			espada_idle.visible = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if lives <= 0:
		return
	
	if area.is_in_group("ProyectilHielo"):
		congelar(1.5)	
		eshielo = true
			
	if area.is_in_group("ProyectilAliado"):
		if area.has_method("morir"):
			area.morir()

		#  comprobar vida ANTES
		var new_lives = lives - 1

		if new_lives <= 0:
			muerte()
			return
		
		# si no muere hacemos knockback aplicar knockback
		hurtSound.play()
		lives = new_lives
		
		if not eshielo:
			var direction = sign(global_position.x - area.global_position.x)
			
			velocity.x = direction * knockback_force

			if is_on_floor():
				velocity.y = knockback_up_force

			knockback_timer = knockback_duration
			in_knockback = true
			
	if area.is_in_group("ataqueCargado"):
		muerte()


func muerte():
	if lives <= 0:
		return
		
	lives = 0
	
	# SUMAR PUNTOS
	GameState.sumar_puntos(10)

	# POPUP VISUAL
	var popup = preload("res://personaje/PointPopup.tscn").instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = global_position + Vector2(0, -40)
	popup.setup("+10")

	aullidoMuerte.play()

	set_collision_layer_value(3, false)
	set_collision_layer_value(4, true)

	set_deferred("monitoring", false)
	remove_from_group("Enemigos")

	if is_instance_valid(espada_sprite):
		espada_sprite.queue_free()

	animated_sprite.play("death")

	await get_tree().create_timer(1.8).timeout
	
	queue_free()
	
func congelar(tiempo):
	if congelado:
		return
	freezeSound.play()
	
	congelado = true
	freeze_timer = tiempo
	
	animated_sprite.modulate = Color(0.1, 0.6, 1)
