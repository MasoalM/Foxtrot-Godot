class_name personaje
extends CharacterBody2D


const velocidad = 300.0
const velocidad_correr = 500.0
const aceleracion = 1000.0
const aceleracion_aire=aceleracion*0.25
const friccion = 1200.0
const JUMP_VELOCITY = -500.0
const bala = preload("res://Proyectiles/proyectil.tscn")

var dobSal = true
var vel
var mirando_derecha = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		dobSal = true
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or dobSal):
		velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			dobSal = false
		
	vel = velocidad
	
	if Input.is_action_pressed("correr"):
		vel = velocidad_correr

	if mirando_derecha && velocity.x < 0:
		$CharacterGreenFront.scale.x *= -1
		$Marker2D.position.x *= -1
		#scale.x *= -1
		mirando_derecha = false

	if not mirando_derecha && velocity.x>0:
		$CharacterGreenFront.scale.x*=-1
		$Marker2D.position.x*=-1
		#scale.x *= -1
		mirando_derecha = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * vel, aceleracion * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friccion * delta)
	else:
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * vel, aceleracion_aire * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friccion * delta)
		
	var shoot = bala.instantiate()
	if Input.is_action_just_pressed("DispararBasico"):
		if get_tree().get_nodes_in_group("ProyectilAliado").size() < 3:
			get_parent().add_child(shoot)
			shoot.position = $Marker2D.global_position
			if not mirando_derecha:
				shoot.scale.x *= -1
				shoot.vel_bala *= -1
	
	move_and_slide()
