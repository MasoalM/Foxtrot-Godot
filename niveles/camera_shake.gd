extends Camera2D

@export var max_offset := Vector2(10.0, 8.0)
@export var max_roll := 0.05
@export var sway_speed := 8.0
@export var decay := 2.5
@export var offset_x := 400
@export var cycle_duration := 5.0

var trauma := 0.0
var time := 0.0

@onready var noise := FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.8

func _process(delta: float) -> void:
	var target_pos = get_parent().global_position
	target_pos.x += offset_x
	global_position = target_pos.round()

	time += delta
	trauma = max(trauma - decay * delta, 0.0)

	# Oscila suavemente entre 0 y 1
	# cycle_duration = tiempo de un ciclo completo (sube + baja)
	# Oscila entre 0 y 1
	var wave := (sin(time * (TAU / cycle_duration)) + 1.0) / 2.0

	# Hace que el pico fuerte dure muy poco
	wave = pow(wave, 4.0)

	var intensity := wave + trauma * trauma

	offset = Vector2(
		sin(time * sway_speed) * max_offset.x * intensity,
		noise.get_noise_1d(time * 10.0) * max_offset.y * intensity
	)
	rotation = noise.get_noise_1d(time * 10.0 + 50.0) * max_roll * intensity

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)
