extends RigidBody2D
const proyectil = preload("res://Proyectiles/proyectilTorreta.tscn")
@onready var shotSound = $AudioStreamPlayer2DShot
@onready var pointLight = $PointLight2D

const shootCooldown = 100
var shootTime = shootCooldown

# Configuración de la luz pulsante
const LIGHT_MIN = 1
const LIGHT_MAX = 3
const PULSE_SPEED = 0.5  # ciclos por segundo
var pulse_time = 0.0

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	# Disparo independiente de FPS
	shootTime -= delta * 60  # Convierte el cooldown a segundos (asume 60fps base)
	if shootTime <= 0:
		var shoot = proyectil.instantiate()
		get_parent().add_child(shoot)
		shoot.position = $Marker2D.global_position
		shoot.scale.x *= -1
		shoot.vel_bala *= -1
		shootTime = shootCooldown 

	# Luz pulsante con delta (independiente de FPS)
	pulse_time += delta * PULSE_SPEED
	var t = (sin(pulse_time * TAU) + 1.0) / 2.0  # oscila entre 0.0 y 1.0
	pointLight.energy = lerp(LIGHT_MIN, LIGHT_MAX, t)
