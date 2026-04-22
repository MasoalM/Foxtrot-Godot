extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

@export var speed := 80.0
@export var jump_interval := 5.0
@export var gravity := 600.0

@export var swim_depth := 50.0
@export var jump_above_surface := 300.0

@export var swim_amplitude := 25.0
@export var swim_speed := 1.2
@export var swim_smoothness := 0.1  

@export var limiteIzquierda := 0.0
@export var limiteDerecha := 0.0

# --- VARIABLES INTERNAS ---
var velocity := Vector2.ZERO
var direction := 1

var surface_y := 0.0
var swim_y := 0.0

var jump_timer := 0.0
var float_time := 0.0

var is_jumping := false

# CONTROL DE ANIMACIONES
var current_anim = ""


var player 

func play_anim(name):
	if current_anim != name:
		current_anim = name
		animated_sprite.play(name)

func _ready():
	play_anim("movement")
	player = get_tree().get_first_node_in_group("player")
	surface_y = position.y
	swim_y = surface_y + swim_depth
	
	jump_timer = randf() * jump_interval

func _physics_process(delta):
	jump_timer += delta

	if player:
		var dir = sign(player.global_position.x - global_position.x)
		velocity.x = dir * speed
		direction = dir

	if is_jumping:
		velocity.y += gravity * delta
		position += velocity * delta

		if position.y >= swim_y:
			position.y = swim_y
			velocity.y = 0
			is_jumping = false
			
			# volver a nadar cuando termina el salto
			play_anim("movement")

	else:
		_apply_swim(delta)
		position.x += velocity.x * delta

		if jump_timer >= jump_interval:
			jump_timer = 0.0
			
			var cerca_izquierda = abs(position.x - limiteIzquierda) < 200
			var cerca_derecha = abs(position.x - limiteDerecha) < 200
			
			if not (cerca_izquierda or cerca_derecha):
				_jump()

	if position.x <= limiteIzquierda:
		direction = 1
	elif position.x >= limiteDerecha:
		direction = -1
		
	animated_sprite.flip_h = direction > 0
		
	_update_rotation(delta)	

func _update_rotation(delta):
	var visual_velocity = velocity
	
	if not is_jumping:
		var wave = cos(float_time * swim_speed) * swim_amplitude * swim_speed
		visual_velocity.y = wave
	
	if visual_velocity.length() > 0.1:
		var angle = visual_velocity.angle() + deg_to_rad(180)
		
		if direction > 0:
			angle += PI
		
		animated_sprite.rotation = lerp_angle(animated_sprite.rotation, angle, 0.1)

# --- salto ---
func _jump():
	float_time = 0.0
	
	# ✅ AQUÍ SE LANZA LA MORDIDA
	play_anim("bite")
	
	var target_y = surface_y - jump_above_surface
	var distance = swim_y - target_y
	velocity.y = -sqrt(2 * gravity * distance)
	is_jumping = true

# --- nadar ---
func _apply_swim(delta):
	float_time += delta * swim_speed
	
	var offset = sin(float_time) * swim_amplitude
	var target_y = swim_y + offset
	
	position.y = lerp(position.y, target_y, swim_smoothness)

# cuando termina la animación bite
func _on_AnimatedSprite2D_animation_finished():
	if current_anim == "bite":
		play_anim("movement")


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
