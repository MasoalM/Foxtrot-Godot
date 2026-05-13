extends CharacterBody2D

@onready var hitbox = $Hitbox
@onready var animated_sprite = $AnimatedSprite2D
@onready var bow = $Bow
@onready var muerteSound = $AudioStreamPlayer2DDeath
@onready var shootSound = $AudioStreamPlayer2DShot

@export var max_vertical_range := 300
@export var gravity := 900
@export var shoot_distance := 400
@export var shoot_cooldown := 1.5
@export var projectile_scene: PackedScene

var popup_scene = preload("res://personaje/PointPopup.tscn")

var player

var shoot_timer := 0.0
var is_dead = false

func _ready():
	add_to_group("Enemigos")
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta):
	if not is_dead:
		# --- GRAVEDAD ---
		if !is_on_floor():
			velocity.y += gravity * delta

		velocity.x = 0  

		# --- LOGICA PRINCIPAL ---
		if player:
			var target_pos = player.global_position + Vector2(0, -20)
			var distance = abs(player.global_position.x - global_position.x)
			
			# --- GIRAR SPRITE ---
			$AnimatedSprite2D.flip_h = player.global_position.x < global_position.x
			
			# --- ROTAR ARCO (CLAVE) ---
			if bow:
				var shot_velocity = get_shot_velocity(target_pos)
				bow.rotation = shot_velocity.angle()
				
				# evitar que se vea al revés
				if player.global_position.x < global_position.x:
					bow.scale.y = -1
				else:
					bow.scale.y = 1
			
			# --- DISPARO ---
			var vertical_distance = abs(player.global_position.y - global_position.y)

			if distance < shoot_distance and vertical_distance < max_vertical_range:
				shoot_timer -= delta
				
				if shoot_timer <= 0:
					if not is_dead:
						animated_sprite.play("preShot")
					
					shoot_timer = 2
					await get_tree().create_timer(1).timeout
					
					shoot()
					shoot_timer = shoot_cooldown
					shootSound.play()
					
					if not is_dead:
						animated_sprite.play("idle")
		move_and_slide()

func get_shot_velocity(target_pos: Vector2) -> Vector2:
	var time = clamp(global_position.distance_to(target_pos) / 300.0, 0.5, 1.5)
	var displacement = target_pos - global_position
	
	var vel = Vector2.ZERO
	vel.x = displacement.x / time
	vel.y = (displacement.y / time) - (0.5 * gravity * time)
	
	return vel

func shoot():
	if is_dead:
		return
	
	if projectile_scene == null:
		return
	
	var bullet = projectile_scene.instantiate()
	get_parent().add_child(bullet)
	
	var spawn_point = bow.get_node("Marker2D")
	
	bullet.global_position = spawn_point.global_position
	bullet.shooter = self
	bullet.shoot_to_target(player.global_position + Vector2(0, -20))

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("ProyectilAliado"):
		if area.has_method("morir"):
			area.morir()
		
		if not is_dead:
			bow.queue_free()
		
		is_dead = true
		
		# Desactivar enemigo, hitbox y colisiones
		remove_from_group("Enemigos")
		
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
		
		set_collision_layer_value(1, false)
		set_collision_layer_value(4, true)
		$Hitbox.set_collision_layer_value(1, false)
		
		# PUNTOS
		GameState.sumar_puntos(10)
		
		# POPUP VISUAL
		var popup = popup_scene.instantiate()
		get_tree().current_scene.add_child(popup)
		
		popup.global_position = global_position + Vector2(0, -40)
		popup.setup("+10")
		
		muerteSound.play()
		
		animated_sprite.play("death")
		await get_tree().create_timer(1.8).timeout
		queue_free()
