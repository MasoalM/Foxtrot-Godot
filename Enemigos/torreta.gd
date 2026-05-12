extends StaticBody2D

const proyectil = preload("res://Proyectiles/proyectilTorreta.tscn")
@onready var shotSound = $AudioStreamPlayer2DShot
@onready var pointLight = $PointLight2D

# --- Enum de dirección (aparece como desplegable en el inspector) ---
enum Direccion {
	DERECHA,
	DERECHA_ABAJO,
	ABAJO,
	IZQUIERDA_ABAJO,
	IZQUIERDA,
	IZQUIERDA_ARRIBA,
	ARRIBA,
	DERECHA_ARRIBA
}

@export var direccion_disparo: Direccion = Direccion.DERECHA

const shootCooldown = 100
var shootTime = shootCooldown

const LIGHT_MIN = 1
const LIGHT_MAX = 3
const PULSE_SPEED = 0.5
var pulse_time = 0.0

# Vectores normalizados para cada dirección del enum
const VECTORES_DIRECCION = {
	0: Vector2(1, 0),
	1: Vector2(0.707, 0.707),
	2: Vector2(0, 1),
	3: Vector2(-0.707, 0.707),
	4: Vector2(-1, 0),
	5: Vector2(-0.707, -0.707),
	6: Vector2(0, -1),
	7: Vector2(0.707, -0.707),
}

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	shootTime -= delta * 60
	if shootTime <= 0:
		_disparar()
		shootTime = shootCooldown * randf_range(0.5, 1.5)

	pulse_time += delta * PULSE_SPEED
	var t = (sin(pulse_time * TAU) + 1.0) / 2.0
	pointLight.energy = lerp(LIGHT_MIN, LIGHT_MAX, t)

func _disparar() -> void:
	var shoot = proyectil.instantiate()
	get_parent().add_child(shoot)
	shoot.position = $Marker2D.global_position

	shotSound.play()
	var dir = VECTORES_DIRECCION[direccion_disparo]
	shoot.direccion = dir
	
	shoot.rotation = dir.angle()
