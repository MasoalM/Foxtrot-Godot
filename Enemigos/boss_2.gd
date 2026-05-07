# boss.gd
extends CharacterBody2D

# ---- Fases ----
@export var phase_1_frames: Array[Texture2D] = []
@export var phase_2_frames: Array[Texture2D] = []
@export var phase_3_frames: Array[Texture2D] = []
@export var phase_4_frames: Array[Texture2D] = []
@export var frame_speed := 8.0
@export var bounds_x := Vector2(320, 1024)   # min X, max X
@export var bounds_y := Vector2(-380, 340)   # min Y, max Y
@export var bounds_y2 := Vector2(-2720.0, 340)   # min Y, max Y
@export var bounds_y3 := Vector2(-4508.0,340) 
var current_phase := 0
var is_dead := false

# ---- Movimiento ----
@export var move_duration := 1.2
@export var move_pause := 0.8
@export var move_speed := 80.0
@export var target_change_interval := 2.0   # cada cuánto cambia de objetivo
@export var velocity_smooth := 4.0          # suavidad (más alto = más brusco)
@export var top_margin := 60.0              # margen para considerar que "llegó arriba"
@export var top_float_range := 150.0   # margen de subida/bajada en la zona alta
var move_target := Vector2.ZERO
var target_timer := 0.0
var has_reached_top := false

# ---- Disparo ----
@export var shoot_interval := 3.0
@export var balls_per_shot := 2
@export var ball_lifetime := 6.0
@export var ball_scene: PackedScene
var shoot_timer := 0.0

# ---- Embestida (fase 4) ----
@export var charge_interval := 8.0
@export var charge_speed := 280.0
var charge_timer := 0.0
var charging := false
var charge_velocity := Vector2.ZERO

# ---- Inmunidad post-golpe ----
@export var immunity_duration := 15.0
var immunity_timer := 0.0
var is_immune := false
var immunity_tween: Tween

# ---- Luz arcoíris fase 4 ----
var rainbow_active := false
var rainbow_time := 0.0

# ---- Cámara ----
var camera: Node

# ---- Aturdimiento ----
@export var hits_to_stun := 5
@export var stun_duration := 5.0
var immune_hit_count := 0
var is_stunned := false
var stun_timer := 0.0

# ---- Referencias ----
@onready var sprite := $AnimatedSprite2D
@onready var hitbox_head := $HitboxHead
@onready var hitbox_body := $HitboxBody

# ---- Sonidos ----
@onready var sfx_hit := $MadBoss
@onready var sfx_shot := $Shot
@onready var sfx_death := $Death
@onready var music: AudioStreamPlayer = $"../AudioStreamPlayer"

# ---- Luz ----
@onready var luz: DirectionalLight2D = $"../DirectionalLight2D"

# ---- Platforms ----
@onready var platform_manager = $"../PlatformManager"
@onready var platform_manager2 = $"../PlatformManager2"
@onready var platform_manager3 = $"../PlatformManager3"

func _ready():
	
	GameState.tiempo_activo = false
	camera = get_tree().get_first_node_in_group("camera")
	_set_phase(0)
	hitbox_head.area_entered.connect(_on_head_area_hit)
	move_target = global_position
	_pick_new_target()
	# --- NUEVO ---
	_start_immunity()
	hitbox_body.area_entered.connect(_on_hitbox_body_area_entered)

func _physics_process(delta):
	if is_dead:
		return

	_process_immunity(delta)
	_process_stun(delta)
	_process_rainbow(delta)

	if charging:
		_process_charge(delta)
		return

	_process_movement(delta)
	_process_shoot(delta)

	if current_phase == 3:
		_process_charge_timer(delta)

	move_and_slide()

# -----------------------------------------------
# LUZ ARCOÍRIS FASE 4
# -----------------------------------------------
func _process_rainbow(delta):
	if not rainbow_active or not luz:
		return
	rainbow_time += delta * 0.08  # muy lento
	var hue := fmod(rainbow_time, 1.0)
	luz.color = Color.from_hsv(hue, 0.8, 1.0)

# -----------------------------------------------
# INMUNIDAD
# -----------------------------------------------
func _process_immunity(delta):
	if not is_immune:
		return
	immunity_timer -= delta
	if immunity_timer <= 0.0:
		is_immune = false
		_stop_immunity_aura()

func _start_immunity():
	is_immune = true
	immunity_timer = immunity_duration
	_play_immunity_aura()

func _play_immunity_aura():
	if immunity_tween:
		immunity_tween.kill()
	immunity_tween = create_tween().set_loops()
	immunity_tween.tween_property(sprite, "modulate", Color(0.5, 0.1, 1.0, 1.0), 0.25)
	immunity_tween.tween_property(sprite, "modulate", Color(0.1, 0.5, 1.0, 0.7), 0.25)
	immunity_tween.tween_property(sprite, "modulate", Color(0.8, 0.0, 1.0, 1.0), 0.25)
	immunity_tween.tween_property(sprite, "modulate", Color(0.0, 0.8, 1.0, 0.6), 0.25)

func _stop_immunity_aura():
	if immunity_tween:
		immunity_tween.kill()
		immunity_tween = null
	sprite.modulate = Color.WHITE
	
func _flash_red():
	sfx_hit.play()
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(2.0, 0.2, 0.2, 1.0), 0.05)
	tween.tween_property(sprite, "modulate", Color(0.5, 0.1, 1.0, 1.0), 0.15)

func _trigger_stun():
	if is_stunned:
		return
	is_stunned = true
	stun_timer = stun_duration
	is_immune = false
	_stop_immunity_aura()
	if camera:
		camera.add_trauma(1.2)
	# Bajar mucho: apuntar al fondo del área
	match current_phase:
		0:
			move_target = Vector2(
			randf_range(bounds_x.x + 40.0, bounds_x.y - 40.0),
			bounds_y.y +200
			)
			has_reached_top = false
		1:
			move_target = Vector2(
				randf_range(bounds_x.x + 40.0, bounds_x.y - 40.0),
				bounds_y2.y +200
			)
			has_reached_top = false
		2:
			move_target = Vector2(
			randf_range(bounds_x.x + 40.0, bounds_x.y - 40.0),
			bounds_y3.y +200
			)
			has_reached_top = false
			

# -----------------------------------------------
# MOVIMIENTO ALEATORIO
# -----------------------------------------------
func _process_movement(delta):
	if is_stunned:
		# Solo moverse hacia el punto de stun
		var desired := (move_target - global_position)
		if desired.length() > move_speed:
			desired = desired.normalized() * move_speed
		
		velocity = velocity.lerp(desired, delta * velocity_smooth)
		return
	# ¿Ha llegado arriba?
	match current_phase:
		0:
			if not has_reached_top and global_position.y <= bounds_y.x + top_margin:
				has_reached_top = true
				_pick_new_target()
		1:
			if not has_reached_top and global_position.y <= bounds_y2.x + top_margin:
				has_reached_top = true
				_pick_new_target()
		2:
			if not has_reached_top and global_position.y <= bounds_y3.x + top_margin:
				has_reached_top = true
				_pick_new_target()
	

	# Actualizar objetivo periódicamente
	target_timer -= delta
	if target_timer <= 0.0:
		_pick_new_target()

	# Velocidad deseada hacia el objetivo
	var desired := (move_target - global_position)
	if desired.length() > move_speed:
		desired = desired.normalized() * move_speed

	# Lerp suave de velocidad
	velocity = velocity.lerp(desired, delta * velocity_smooth)

func _pick_new_target():
	target_timer = randf_range(target_change_interval * 0.6, target_change_interval)

	var new_x := randf_range(bounds_x.x + 40.0, bounds_x.y - 40.0)
	var new_y: float

	match current_phase:
		0:
			if has_reached_top:
				# Oscila por encima y por debajo del techo
				new_y = bounds_y.x + randf_range(-top_float_range * 0.3, top_float_range)
			else:
				new_y = bounds_y.x
		1:
			if has_reached_top:
				# Oscila por encima y por debajo del techo
				new_y = bounds_y2.x + randf_range(-top_float_range * 0.3, top_float_range)
			else:
				new_y = bounds_y2.x
		2:
			if has_reached_top:
				# Oscila por encima y por debajo del techo
				new_y = bounds_y3.x + randf_range(-top_float_range * 0.3, top_float_range)
			else:
				new_y = bounds_y3.x
	

	move_target = Vector2(new_x, new_y)
# -----------------------------------------------
# DISPARO
# -----------------------------------------------
func _process_shoot(delta):
	if is_dead or is_stunned:
		return
	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = shoot_interval
		_shoot()

func _shoot():
	if ball_scene == null or is_dead:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	for i in range(balls_per_shot):
		await get_tree().create_timer(i * randf_range(0.2, 0.6)).timeout
		if is_dead or not is_instance_valid(player) or not is_inside_tree():
			return
		sfx_shot.play()
		if camera:
			camera.add_trauma(0.6)
		var ball = ball_scene.instantiate()
		get_parent().add_child(ball)
		ball.global_position = global_position
		ball.set_target(player)
		ball.set_shooter(self)
		if "lifetime" in ball:
			ball.lifetime = ball_lifetime
		var base_dir = (player.global_position - global_position).normalized()
		ball.velocity = base_dir.rotated(randf_range(-0.4, 0.4)) * ball.speed

# -----------------------------------------------
# TELEPORTE
# -----------------------------------------------
func _teleport_effect():
	if is_dead:
		return
	if camera:
		camera.add_trauma(0.7)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
	tween.tween_property(sprite, "modulate",
		Color.WHITE if not is_immune else Color(0.7, 0.2, 1.0), 0.15)
	var scale_tween := create_tween()
	scale_tween.tween_property(sprite, "scale", Vector2(1.4, 0.7), 0.08)
	scale_tween.tween_property(sprite, "scale",
		Vector2(1.3, 1.3) if current_phase == 3 else Vector2(1.0, 1.0),
		0.15).set_trans(Tween.TRANS_ELASTIC)
	_shoot_burst()

func _shoot_burst():
	if is_dead:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null or ball_scene == null:
		return
	for i in range(3):
		await get_tree().create_timer(i * 0.1).timeout
		if is_dead or not is_inside_tree():
			return
		sfx_shot.play()
		var ball = ball_scene.instantiate()
		get_parent().add_child(ball)
		ball.global_position = global_position
		ball.set_target(player)
		ball.set_shooter(self)
		if "lifetime" in ball:
			ball.lifetime = ball_lifetime
		var base_dir = (player.global_position - global_position).normalized()
		ball.velocity = base_dir.rotated(deg_to_rad(-20 + i * 20)) * ball.speed

# -----------------------------------------------
# EMBESTIDA
# -----------------------------------------------
func _process_charge_timer(delta):
	if is_dead:
		return
	charge_timer -= delta
	if charge_timer <= 0.0:
		charge_timer = charge_interval
		_telegraph_charge()

func _telegraph_charge():
	if is_dead:
		return
	var tween := create_tween()
	for i in range(4):
		tween.tween_callback(func(): sprite.modulate = Color(1, 0.2, 0.2))
		tween.tween_interval(0.15)
		tween.tween_callback(func(): sprite.modulate = Color.WHITE)
		tween.tween_interval(0.15)
	tween.tween_callback(_start_charge)

func _start_charge():
	if is_dead:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	charging = true
	global_position = player.global_position + Vector2(randf_range(-150, 150), -350)
	_teleport_effect()
	charge_velocity = (player.global_position - global_position).normalized() * charge_speed
	if camera:
		camera.add_trauma(0.4)

func _process_charge(delta):
	if is_dead:
		charging = false
		return
	global_position += charge_velocity * delta
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.y > player.global_position.y + 80:
		charging = false
		velocity = Vector2.ZERO
		if camera:
			camera.add_trauma(0.7)
		sprite.play("idle")
		charge_timer = charge_interval
		move_target = global_position  # parte desde donde está
		_pick_new_target()

# -----------------------------------------------
# FASES
# -----------------------------------------------
func _set_phase(phase: int):
	current_phase = phase
	var frames_list: Array[Texture2D]
	match phase:
		0: frames_list = phase_1_frames
		1: frames_list = phase_2_frames
		2: frames_list = phase_3_frames
		3: frames_list = phase_4_frames

	var sf := SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_speed("idle", frame_speed)
	sf.set_animation_loop("idle", true)
	for tex in frames_list:
		sf.add_frame("idle", tex)
	sprite.sprite_frames = sf
	sprite.play("idle")
	shoot_timer = shoot_interval

	if phase == 1:
		move_speed += 40.0

	if phase == 3:
		charge_timer = charge_interval
		move_speed += 20.0
		shoot_interval = max(shoot_interval - 0.5, 1.5)

		if camera:
			camera.set_intensity_multiplier(10)
			camera.max_offset = Vector2(20.0, 14.0)
			camera.max_roll = 0.12

		if luz:
			var tween_luz := create_tween()
			tween_luz.tween_property(luz, "energy", 2.5, 1.0).set_trans(Tween.TRANS_SINE)
			tween_luz.parallel().tween_property(luz, "color", Color(1.0, 0.15, 0.1), 1.0)
			tween_luz.tween_callback(func(): rainbow_active = true)

		var scale_tween := create_tween()
		scale_tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.4).set_trans(Tween.TRANS_ELASTIC)

func _on_head_area_hit(area: Area2D):
	if not area.is_in_group("DoubleJumpShot"):
		return


	if is_immune:
		if camera:
			camera.add_trauma(0.2)
		return
	
	area.morirahora()
	sfx_hit.play()

	if camera:
		camera.add_trauma(0.8)
	
	_advance_phase()

func _advance_phase():
	if current_phase < 3:
		_set_phase(current_phase + 1)
		if (current_phase==1):
			platform_manager2.start()
		if (current_phase==2):
			platform_manager3.start()
		if camera:
			camera.add_trauma(1.0)
		_flash_transition()
		_start_immunity()
		if current_phase == 3:
			_acelerar_musica()
	else:
		_die()

func _flash_transition():
	var tween := create_tween()
	for i in range(8):
		tween.tween_callback(func():
			sprite.modulate = Color(1.5, 1.5, 1.5) if i % 2 == 0 else Color(0.7, 0.2, 1.0))
		tween.tween_interval(0.07)
	tween.tween_callback(func():
		if is_immune:
			_play_immunity_aura())

# -----------------------------------------------
# MUERTE
# -----------------------------------------------
func _die():
	if is_dead:
		return
	is_dead = true
	rainbow_active = false

	# Desactivar hitboxes inmediatamente
	hitbox_body.monitoring = false
	hitbox_body.monitorable = false
	hitbox_head.monitoring = false
	hitbox_head.monitorable = false

	# Parar inmunidad
	if immunity_tween:
		immunity_tween.kill()
		immunity_tween = null
	sprite.modulate = Color.WHITE

	# Eliminar bolas
	for ball in get_tree().get_nodes_in_group("EnemyBall"):
		if is_instance_valid(ball):
			ball.queue_free()

	# Plataformas desaparecen
	if platform_manager:
		var tween_plat := create_tween()
		tween_plat.tween_property(platform_manager, "modulate:a", 0.0, 1.0)
		tween_plat.tween_callback(func(): platform_manager.set_process(false))

	# Música fade out
	if music:
		var tween_music := create_tween()
		tween_music.tween_property(music, "volume_db", -40.0, 1.0)
		tween_music.tween_callback(func(): music.stop())

	# Sonido muerte una sola vez
	sfx_death.stop()
	sfx_death.play()

	# Golpe de cámara y luego para completamente
	if camera:
		camera.add_trauma(3.0)
	await get_tree().create_timer(0.5).timeout
	if camera:
		camera.stop_shake()

	# Luz pasa a amarilla
	if luz:
		var tween_luz := create_tween()
		tween_luz.tween_property(luz, "energy", 1.0, 2.0).set_trans(Tween.TRANS_SINE)
		tween_luz.parallel().tween_property(luz, "color", Color(1.0, 0.85, 0.2), 2.0).set_trans(Tween.TRANS_SINE)

	# Animación de muerte
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.3).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(func():
		visible = false
		await get_tree().create_timer(sfx_death.stream.get_length()).timeout
		queue_free()
	)

func _acelerar_musica():
	var tween := create_tween()
	tween.tween_property(music, "pitch_scale", 1.3, 1.5).set_trans(Tween.TRANS_SINE)


func _on_hitbox_body_area_entered(area: Area2D) -> void:
	if area.is_in_group("ProyectilAliado") and not is_immune and not is_stunned:
		_flash_red()
		immune_hit_count += 1
		if immune_hit_count >= hits_to_stun:
			immune_hit_count = 0
			_trigger_stun()
		return
	pass # Replace with function body.
	
func _process_stun(delta):
	if not is_stunned:
		return
	stun_timer -= delta
	if stun_timer <= 0.0:
		is_stunned = false
		shoot_timer = shoot_interval  # reset para no disparar nada más salir
		_pick_new_target()
