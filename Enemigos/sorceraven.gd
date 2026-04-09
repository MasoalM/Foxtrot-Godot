extends CharacterBody2D

@export var speed := 80.0
@export var gravity := 900.0
@export var shoot_cooldown := 5.0
@export var projectile_scene: PackedScene

@onready var ray_suelo = $RayCastSuelo
@onready var ray_vision = $RayCastVision
@onready var shoot_point = $ShootPoint
@onready var sprite = $Sprite2D

var direction := 1
var player
var shoot_timer := 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# --- GRAVEDAD ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- VISIÓN ---
	var ve_jugador = can_see_player()

	if ve_jugador and is_instance_valid(player):
		# --- PARADO ---
		velocity.x = 0
		
		# --- MIRAR AL PLAYER ---
		if player.global_position.x > global_position.x:
			direction = 1
		else:
			direction = -1

		# --- DISPARO ---
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot_timer = shoot_cooldown
			shoot()

	else:
		# --- MOVIMIENTO NORMAL ---
		velocity.x = speed * direction

		# --- DETECTAR BORDE ---
		if ray_suelo and not ray_suelo.is_colliding():
			_flip()

		# --- DETECTAR PARED ---
		if is_on_wall():
			_flip()

	move_and_slide()

	# --- FLIP VISUAL ---
	sprite.flip_h = direction > 0


func _flip():
	direction *= -1
	
	# invertir raycasts de forma segura
	if ray_suelo:
		ray_suelo.target_position.x = abs(ray_suelo.target_position.x) * direction
	
	if ray_vision:
		ray_vision.target_position.x = abs(ray_vision.target_position.x) * direction



func shoot():
	if projectile_scene == null:
		return
	
	if not is_instance_valid(player):
		return
	
	var bullet = projectile_scene.instantiate()

	var dir = sign(player.global_position.x - global_position.x)

	if dir == 0:
		dir = 1

	bullet.global_position = shoot_point.global_position + Vector2(dir * 20, 0)

	bullet.set_target(player)
	bullet.set_shooter(self)
	bullet.set_direction_from_target(player)

	get_parent().add_child(bullet)

	# opcional (si implementaste shooter en el proyectil)
	if "shooter" in bullet:
		bullet.shooter = self

	get_parent().add_child(bullet)



func can_see_player():
	if not is_instance_valid(player) or ray_vision == null:
		return false

	var origin = global_position + Vector2(direction * 20, -10)
	var target_pos = player.global_position
	
	var dir = target_pos - origin
	
	ray_vision.global_position = origin
	ray_vision.target_position = dir.normalized() * 800
	ray_vision.force_raycast_update()

	if ray_vision.is_colliding():
		var collider = ray_vision.get_collider()

		if collider and collider.is_in_group("player"):
			return true

	return false

	


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("ProyectilAliado"):
		if area.has_method("morir"):
			area.morir()
		queue_free()	
