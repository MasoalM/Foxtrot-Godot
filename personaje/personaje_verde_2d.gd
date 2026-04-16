extends CharacterBody2D

@onready var animacion = $AnimatedSprite2D
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
@onready var dust = preload("res://Sprites/Particles/Dust.tscn")
@onready var doubleJumpParticles = preload("res://Sprites/Particles/DoubleJumpParticles.tscn")
@onready var shotSound = $AudioStreamPlayer2DShot
@onready var shieldSound = $AudioStreamPlayer2DShield
@onready var healSound = $AudioStreamPlayer2DHeal
@onready var jumpSound = $AudioStreamPlayer2DJump
@onready var coinSound = $AudioStreamPlayer2DCoin
@onready var walkSound = $AudioStreamPlayer2DWalk
@onready var damageSound = $AudioStreamPlayer2DDamage
@onready var iceSound = $AudioStreamPlayer2DIce
@onready var doubleJumpPowerUpSound = $AudioStreamPlayer2DDoubleJumpPowerUp
@onready var oneUpSound = $AudioStreamPlayer2DOneUp
@onready var firePowerUpSound = $AudioStreamPlayer2DFirePowerUp


var monedas_estado = [false, false, false]

signal vidas_cambiadas(vidas, escudo)
signal monedas_cambiadas(monedas_estado)

const velocidad = 300.0
const velocidad_correr = 450.0
const aceleracion = 1000.0
const aceleracion_aire = aceleracion * 0.5
const friccion = 1200.0
const JUMP_VELOCITY = -525.0
const cut_factor = 0.5
const bala = preload("res://Proyectiles/proyectil.tscn")
const bala_hielo = preload("res://Proyectiles/proyectil_hielo.tscn")
const ataqueCargado = preload("res://powerUps/ataque_cargado.tscn")
const coyoteTime = 10
const afk = 400

var realAFK = 0
var walk_timer = 0.0
var afkAnimation = false
var isShooting = false
var correr = false
var aire = false
var is_hurt = false
var is_dead = false
var bloquearControles = false
var is_jumping = false
var is_fall = false
var isGrounded = true

var proyectil_actual
var dobSalAct = false
var guanteActivo = false
var dobSal = false
var ataqueCarg = false
var tween_parpadeo
var vel
var mirando_derecha = true
var air_nercia = false
var coyoteTimeActual = coyoteTime

var vidas = 2
var escudo = 0
var enemigosIn = 0

var shoot_cooldown = 0.2
var shoot_timer = 0
var shoot_anim_timeout = 0.0
const SHOOT_ANIM_MAX = 1.0

var hurt_timer = 0.0
const HURT_DURATION = 1.0

func _ready():
	proyectil_actual = bala
	
	if GameState.checkpoint_activo:
		global_position = GameState.checkpoint_position
	
	emit_signal("vidas_cambiadas", vidas, escudo)


func _reset_afk() -> void:
	# Interrumpe y resetea el AFK ante cualquier acción jugable
	realAFK = 0
	if afkAnimation:
		afkAnimation = false


func _physics_process(delta: float) -> void:
	if !isGrounded and is_on_floor():
		var instance = dust.instantiate()
		instance.global_position = $DustMarker.global_position
		get_parent().add_child(instance)
	
	if not is_dead:
		if hurt_timer > 0:
			hurt_timer -= delta
			if hurt_timer <= 0:
				is_hurt = false
				state_machine.travel("static")
	
	isGrounded = is_on_floor()
	
	if isShooting:
		shoot_anim_timeout += delta
		if shoot_anim_timeout >= SHOOT_ANIM_MAX:
			isShooting = false
			shoot_anim_timeout = 0.0
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
		# Si quisiésemos poner partículas al saltar	
		#if is_jumping and isGrounded:
		#	var instance = dust.instantiate()
		#	instance.global_position = $DustMarker2.global_position
		#	get_parent().add_child(instance)
		if Input.is_action_pressed("correr"):
			air_nercia = true
		velocity.y = JUMP_VELOCITY
		jumpSound.play()
		if not is_on_floor() and coyoteTimeActual <= 0:
			var instance2 = doubleJumpParticles.instantiate()
			instance2.global_position = $DoubleJumpMarker.global_position
			get_parent().add_child(instance2)
			dobSal = false

	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= cut_factor

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

		# ATAQUE CARGADO
		if ataqueCarg:
			ataqueCarg = false
			parar_parpadeo_cargado()
			shoot_timer = shoot_cooldown
			hacer_ataque_cargado()
			
			return

		# DISPARO NORMAL
		if get_tree().get_nodes_in_group("ProyectilAliado").size() < 3:
			shoot_timer = shoot_cooldown
			var shoot = proyectil_actual.instantiate()
			shotSound.play()
			get_parent().add_child(shoot)
			shoot.position = $Marker2D.global_position

			if not mirando_derecha:
				shoot.scale.x *= -1
				shoot.vel_bala *= -1

	move_and_slide()
	if is_on_floor() and abs(velocity.x) > velocidad/4:
		walk_timer -= 0.008
		if walk_timer <= 0:
			walkSound.volume_db = randf_range(12, 15)
			# velocidad de pasos
			if correr and abs(velocity.x) > velocidad_correr/2:
				walkSound.pitch_scale = randf_range(2, 2.5)
				walk_timer = 0.1   # pasos rápidos
			else: 
				walkSound.pitch_scale = randf_range(1, 1.5)
				walk_timer = 0.25  # pasos normales
			walkSound.play()
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
			doubleJumpPowerUpSound.play()
			dobSalAct = true
		"escudo":
			shieldSound.play()
			var cantidad = 2

			# Curar primero si falta vida
			if vidas < 2:
				var vida_faltante = 2 - vidas
				var curacion = min(cantidad, vida_faltante)
				
				vidas += curacion
				
				flash(1)  # opcional pero queda muy bien

			# Lo restante se convierte en escudo
			if cantidad > 0:
				escudo += cantidad
				escudo = clamp(escudo, 0, 2)
			flash(1)	

			emit_signal("vidas_cambiadas", vidas, escudo)
		"vida":
			if vidas < 2:
				healSound.play()
				vidas = 2
				emit_signal("vidas_cambiadas", vidas, escudo)
				flash(2)
		"guante":
			firePowerUpSound.play()
			ataqueCarg = true
			iniciar_parpadeo_cargado()
		"hielo":
			iceSound.play()
			proyectil_actual = bala_hielo	
		"OneUp":
			oneUpSound.play()
			GameState.ganar_vida()	
			
				


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemigos"):
		enemigosIn -= 1


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemigos"):
		enemigosIn += 1
		_dañar()
			
# Detectar entrada en áreas
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemigos"):
		_dañar()	

func _animaciones() -> void:
	# Hurt y death tienen prioridad absoluta, nada los interrumpe
	if is_dead or is_hurt:
		return

	
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
			state_machine.travel("static")
		
		"shoot":
			isShooting = false
			is_jumping = false
			is_fall = false
			#state_machine.travel("static")
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
		state_machine.travel("static")
		#  Primero escudo
		damageSound.play()
		if escudo > 0:
			is_hurt = true;
			state_machine.travel("hurt")
			escudo -= 1
			# Reemplaza las dos líneas "is_hurt = true" por esto en ambos sitios:	
			is_hurt = true
			hurt_timer = HURT_DURATION
			emit_signal("vidas_cambiadas", vidas, escudo)
			# efecto visual distinto opcional
			flash(3)
			return
		vidas -= 1
		# Reemplaza las dos líneas "is_hurt = true" por esto en ambos sitios:
		is_hurt = true
		hurt_timer = HURT_DURATION 
		emit_signal("vidas_cambiadas", vidas, escudo)
		if vidas <= 0:
			is_dead = true
			bloquearControles = true
			state_machine.travel("death")

			GameState.perder_vida()

			await get_tree().create_timer(1.0).timeout

			if GameState.vidas_juego > 0:
				if GameState.checkpoint_activo:
					get_tree().reload_current_scene()
				else:
					get_tree().reload_current_scene()
			else:
				print("mox ha muerto y no le quedan vidas")
				GameState.reiniciar()
				get_tree().reload_current_scene()
				
		else:
			is_hurt = true
			state_machine.travel("hurt")
			flash(3)
			

	
func flash(color):
	for i in range(3):
		if color == 3:
			animacion.modulate = Color(1, 0.2, 0.2)
		if color == 2:
			animacion.modulate = Color(0.2, 1, 0.2)
		if color == 1:
			animacion.modulate = Color(0.1, 0.6, 1)	
		await get_tree().create_timer(0.15).timeout
		
		animacion.modulate = Color(1, 1, 1)  
		await get_tree().create_timer(0.15).timeout

	# asegurar que termina limpio
	animacion.modulate = Color(1, 1, 1)			
	


func recoger_moneda(id):
	if not GameState.monedas_estado[id]:
		GameState.monedas_estado[id] = true
		coinSound.play()
		GameState.emit_signal("monedas_cambiadas", GameState.monedas_estado)
		
func hacer_ataque_cargado():
	var atk = ataqueCargado.instantiate()
	get_parent().add_child(atk)
	atk.global_position = global_position
	
func iniciar_parpadeo_cargado():
	if tween_parpadeo:
		tween_parpadeo.kill()
	
	tween_parpadeo = create_tween().set_loops()
	
	tween_parpadeo.tween_property(animacion, "modulate",
		Color(1, 1, 0.2), 0.5)
	
	tween_parpadeo.tween_property(animacion, "modulate",
		Color(1, 1, 1), 0.5)	
		
func parar_parpadeo_cargado():
	if tween_parpadeo:
		tween_parpadeo.kill()
		tween_parpadeo = null
	
	animacion.modulate = Color(1, 1, 1)		

#func _on_area_2d_area_entered(area: Area2D) -> void:
#	if area.is_in_group("Lianas"):
#		print("the end is never the end is never the end is never the end is never the end is never the end is never ") 
