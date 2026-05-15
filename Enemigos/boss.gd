# boss.gd
extends CharacterBody2D

# ---- Fases ----
@export var phase_1_frames: Array[Texture2D] = []
@export var phase_2_frames: Array[Texture2D] = []
@export var phase_3_frames: Array[Texture2D] = []
@export var phase_4_frames: Array[Texture2D] = []
@export var frame_speed := 8.0
var current_phase := 0
var is_dead := false

# ---- Movimiento ----
@export var move_speed := 80.0
@export var move_duration := 1.2
@export var move_pause := 0.8
var move_timer := 0.0
var pause_timer := 0.0
var moving := false
var move_direction := Vector2.ZERO

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

# ---- Referencias ----
@onready var sprite := $AnimatedSprite2D
@onready var hitbox_head := $HitboxHead
@onready var hitbox_body := $HitboxBody

# ---- Sonidos ----
@onready var music: AudioStreamPlayer = $"../AudioStreamPlayer"
var sfx_hit: AudioStreamPlayer
var sfx_shot: AudioStreamPlayer
var sfx_death: AudioStreamPlayer

# ---- Luz ----
@onready var luz: DirectionalLight2D = $"../DirectionalLight2D"

# ---- Platforms ----
@onready var platform_manager = $"../PlatformManager"

func _ready():
	GameState.tiempo_activo = false
	
	camera = get_tree().get_first_node_in_group("camera")
	_set_phase(0)
	_start_new_move()
	
	# Prepare sounds
	sfx_hit = AudioManager.get_player("MadBoss")
	sfx_hit.volume_db = 10.0
	
	sfx_shot = AudioManager.get_player("Portal")
	sfx_shot.volume_db = -5.0
	sfx_shot.pitch_scale = 0.75
	
	sfx_death = AudioManager.get_player("MadBoss")
	sfx_death.volume_db = 10.0
	sfx_death.pitch_scale = 0.25

func _physics_process(delta):
	if is_dead:
		return

	_process_immunity(delta)
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

# -----------------------------------------------
# MOVIMIENTO ALEATORIO
# -----------------------------------------------
func _process_movement(delta):
	if moving:
		move_timer -= delta
		velocity = move_direction * move_speed

		var bounds_x := Vector2(150, 950)
		var bounds_y := Vector2(150, 450)

		if global_position.x <= bounds_x.x:
			move_direction.x = abs(move_direction.x)
		elif global_position.x >= bounds_x.y:
			move_direction.x = -abs(move_direction.x)

		if global_position.y <= bounds_y.x:
			move_direction.y = abs(move_direction.y)
		elif global_position.y >= bounds_y.y:
			move_direction.y = -abs(move_direction.y)

		if velocity.length() > 0 and get_real_velocity().length() < 5.0:
			_start_new_move()
			return

		if move_timer <= 0.0:
			moving = false
			velocity = Vector2.ZERO
			pause_timer = randf_range(0.3, move_pause)
	else:
		pause_timer -= delta
		velocity = Vector2.ZERO
		if pause_timer <= 0.0:
			_start_new_move()

func _start_new_move():
	var directions = [
		Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN,
		Vector2(-1, -1).normalized(), Vector2(1, -1).normalized(),
		Vector2(-1,  1).normalized(), Vector2(1,  1).normalized(),
	]
	var weights = [3, 3, 2, 1, 2, 2, 1, 1]
	var pool: Array[Vector2] = []
	for i in range(directions.size()):
		for j in range(weights[i]):
			pool.append(directions[i])

	var new_dir: Vector2
	var attempts := 0
	while attempts < 10:
		new_dir = pool[randi() % pool.size()]
		if new_dir != move_direction:
			break
		attempts += 1

	move_direction = new_dir
	move_timer = randf_range(0.6, move_duration)
	moving = true

# -----------------------------------------------
# DISPARO
# -----------------------------------------------
func _process_shoot(delta):
	if is_dead:
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
		_start_new_move()

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

func _on_hitbox_head_area_entered(area: Area2D):
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
	hitbox_body.set_deferred("monitoring", false)
	hitbox_body.set_deferred("monitorable", false)
	hitbox_head.set_deferred("monitoring", false)
	hitbox_head.set_deferred("monitorable", false)

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
