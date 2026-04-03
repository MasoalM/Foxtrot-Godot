extends CharacterBody2D
@onready var hand = $Hand
@onready var sword = $Hand/Sword
@export var gravity := 900
@export var shoot_distance := 400
@export var shoot_cooldown := 1.5
@export var projectile_scene: PackedScene
@onready var hitbox = $Hitbox
@onready var animated_sprite = $AnimatedSprite2D

@onready var bow = $Bow   

var player
var shoot_timer := 0.0
var dead = false

func _ready():
	add_to_group("Enemigos")
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta):
	if !dead:
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
			if distance < shoot_distance:
				shoot_timer -= delta

				if shoot_timer <= 0 and !dead:
					animated_sprite.play("preShot")
					shoot_timer = 2
					await get_tree().create_timer(1).timeout
					shoot()
					shoot_timer = shoot_cooldown
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
	if !dead:
		print("DISPARANDO")

		if projectile_scene == null:
			print("NO HAY FLECHA ASIGNADA")
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
		dead = true
		#bow.queue_free()
		animated_sprite.play("death")
		await get_tree().create_timer(1.8).timeout
		queue_free()	
