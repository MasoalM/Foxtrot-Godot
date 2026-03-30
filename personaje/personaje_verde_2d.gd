extends CharacterBody2D


@onready var animacion = $AnimatedSprite2D
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")

signal vidas_cambiadas(nuevas_vidas)

const velocidad = 300.0
const velocidad_correr = 450.0
const aceleracion = 1000.0
const aceleracion_aire = aceleracion * 0.5
const friccion = 1200.0
const JUMP_VELOCITY = -500.0
const bala = preload("res://Proyectiles/proyectil.tscn")
const coyoteTime = 10
const afk = 400

var realAFK = 0
var afkAnimation = false
var isShooting = false
var correr = false
var aire = false
var is_hurt = false
var is_dead = false
var bloquearControles = false
var is_jumping = false
var is_fall = false

var dobSalAct = false
var dobSal = false
var vel
var mirando_derecha = true
var air_nercia = false
var coyoteTimeActual = coyoteTime

var vidas = 2
var escudo = 0
var enemigosIn = 0

var shoot_cooldown = 0.2
var shoot_timer = 0


func _ready():
	emit_signal("vidas_cambiadas", vidas)
	pass


func _reset_afk() -> void:
	# Interrumpe y resetea el AFK ante cualquier acción jugable
	realAFK = 0
	if afkAnimation:
		afkAnimation = false


func _physics_process(delta: float) -> void:
	_animaciones()
	# Gravedad
	if not is_on_floor():
		coyoteTimeActual -= 1
		velocity += get_gravity() * delta
	else:
		coyoteTimeActual = coyoteTime
		air_nercia = false
		if dobSalAct == true:
			dobSal = true

	if aire:
		_reset_afk()

	realAFK += 1

	# Salto
	if (not bloquearControles) and Input.is_action_just_pressed("ui_accept") \
			and (is_on_floor() or (coyoteTimeActual > 0) or dobSal):
		_reset_afk()
		aire = true
		if Input.is_action_pressed("correr"):
			air_nercia = true
		velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			dobSal = false

	vel = velocidad
	if ((not bloquearControles) and Input.is_action_pressed("correr") and is_on_floor()) or air_nercia:
		vel = velocidad_correr
		correr = true
	else:
		correr = false

	# Voltear sprite
	if mirando_derecha and velocity.x < 0:
		$CharacterGreenFront.scale.x *= -1
		$Marker2D.position.x *= -1
		$AnimatedSprite2D.scale.x *= -1
		mirando_derecha = false
	if not mirando_derecha and velocity.x > 0:
		$CharacterGreenFront.scale.x *= -1
		$AnimatedSprite2D.scale.x *= -1
		$Marker2D.position.x *= -1
		mirando_derecha = true

	# Movimiento
	if is_on_floor():
		if aire:
			aire = false
		if not bloquearControles:
			var direction := Input.get_axis("ui_left", "ui_right")
			if direction != 0:
				_reset_afk()
				velocity.x = move_toward(velocity.x, direction * vel, aceleracion * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, friccion * delta)
	else:
		if not bloquearControles:
			var direction := Input.get_axis("ui_left", "ui_right")
			if direction != 0:
				velocity.x = move_toward(velocity.x, direction * vel, aceleracion_aire * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, friccion * delta)

	# Disparo
	if shoot_timer > 0:
		shoot_timer -= delta

	if (not bloquearControles) and Input.is_action_just_pressed("DispararBasico") and (shoot_timer <= 0):
		_reset_afk()
		if get_tree().get_nodes_in_group("ProyectilAliado").size() < 3:
			shoot_timer = shoot_cooldown
			var shoot = bala.instantiate()  # ← instanciar solo cuando se necesita
			get_parent().add_child(shoot)
			shoot.position = $Marker2D.global_position
			if not mirando_derecha:
				shoot.scale.x *= -1
				shoot.vel_bala *= -1

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is TileMap:
			var tile_data = collision.get_collider().get_cell_tile_data(1, collision.get_collider().local_to_map(collision.get_position()))
 			#if tile_data:
			#print("damage:", tile_data.get_custom_data("damage"))
			if tile_data and tile_data.get_custom_data("damage"):
				_dañar()
	


func apply_powerup(type):
	match type:
		"dobSal":
			dobSalAct = true
		"escudo":
			escudo = 2
		"vida":
			if vidas < 2:
				vidas = 2
				emit_signal("vidas_cambiadas", vidas)
				flash_heal()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemigos"):
		enemigosIn -= 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemigos"):
		enemigosIn += 1
		_dañar()
			
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemigos"):
		_dañar()			
			
			


func _animaciones() -> void:
	# Hurt y death tienen prioridad absoluta, nada los interrumpe
	if is_dead or is_hurt:
		return

	# ↓ MOVIDO AQUÍ: el disparo interrumpe también jump y fall
	if (not bloquearControles) and Input.is_action_just_pressed("DispararBasico") and (shoot_timer <= 0):
		if get_tree().get_nodes_in_group("ProyectilAliado").size() < 3:
			isShooting = true
			state_machine.travel("shoot")
			return

	if isShooting:
		return

	if is_jumping:
		return

	if is_fall:
		return

	# Transición aire → aterrizaje
	if state_machine.get_current_node() == "air" and is_on_floor():
		is_fall = true
		state_machine.travel("fall")
		return

	# En el aire
	if not is_on_floor():
		state_machine.travel("air")
		return

	# Salto (solo se registra estando en el suelo)
	if (not bloquearControles) and Input.is_action_just_pressed("ui_accept"):
		is_jumping = true
		state_machine.travel("jump")
		return

	# AFK: se activa si se supera el umbral de inactividad
	if realAFK >= afk and not afkAnimation:
		afkAnimation = true
		state_machine.travel("afk")
		return

	# Mientras AFK está activo, no cambiar de animación
	if afkAnimation:
		return

	# Animaciones de movimiento en suelo
	if velocity.x == 0:
		state_machine.travel("static")
	elif abs(velocity.x) < velocidad_correr:
		state_machine.travel("idle")
	else:
		state_machine.travel("running")


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"death":
			queue_free()

		"hurt":
			is_hurt = false
			if enemigosIn > 0:
				vidas -= 1
				if vidas <= 0:
					is_dead = true
					bloquearControles = true
					state_machine.travel("death")
				else:
					is_hurt = true
					state_machine.travel("hurt")

		"shoot":
			isShooting = false
			is_jumping = false
			is_fall = false

		"jump":
			# Al acabar el impulso visual, pasar a la animación de vuelo
			is_jumping = false
			state_machine.travel("air")

		"fall":
			# Al acabar el aterrizaje, volver al estado normal
			is_fall = false

		"afk":
			# Al acabar el AFK, esperar el mismo tiempo antes de repetir
			afkAnimation = false  # ← era "==" antes, bug corregido
			realAFK = 0
			state_machine.travel("static")

func _dañar():
		if is_hurt or is_dead:
			return
		vidas -= 1
		emit_signal("vidas_cambiadas", vidas)
		if vidas <= 0:
			is_dead = true
			bloquearControles = true
			state_machine.travel("death")
		else:
			flash_damage()
			is_hurt = true
			state_machine.travel("hurt")
			
func flash_damage():
	for i in range(3):
		animacion.modulate = Color(1, 0.2, 0.2)  
		await get_tree().create_timer(0.15).timeout
		
		animacion.modulate = Color(1, 1, 1)  
		await get_tree().create_timer(0.15).timeout

	# asegurar que termina limpio
	animacion.modulate = Color(1, 1, 1)			

func flash_heal():
	for i in range(2):
		animacion.modulate = Color(0.2, 1, 0.2)  # verde
		await get_tree().create_timer(0.15).timeout
		
		animacion.modulate = Color(1, 1, 1)  # normal
		await get_tree().create_timer(0.15).timeout

	# asegurar reset final
	animacion.modulate = Color(1, 1, 1)	
#func _on_area_2d_area_entered(area: Area2D) -> void:
#	if area.is_in_group("Lianas"):
#		print("the end is never the end is never the end is never the end is never the end is never the end is never ")
