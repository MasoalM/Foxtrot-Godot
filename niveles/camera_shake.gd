# camera.gd
extends Camera2D

@export var max_offset := Vector2(10.0, 8.0)
@export var max_roll := 0.05
@export var sway_speed := 8.0
@export var decay := 2.5
@export var offset_x := 400
@export var cycle_duration := 5.0

var trauma := 0.0
var time := 0.0
var intensity_multiplier := 1.0
var shake_enabled := true

@onready var noise := FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.8

func _process(delta: float) -> void:
	var target_pos = get_parent().global_position
	target_pos.x += offset_x
	global_position = target_pos.round()

	if not shake_enabled:
		offset = Vector2.ZERO
		rotation = 0.0
		return

	time += delta
	trauma = max(trauma - decay * delta, 0.0)

	var wave := ((sin(time * (TAU / cycle_duration)) + 1.0) / 2.0) * intensity_multiplier
	wave = pow(wave, 4.0)
	var intensity := wave + trauma * trauma

	offset = Vector2(
		sin(time * sway_speed) * max_offset.x * intensity,
		noise.get_noise_1d(time * 10.0) * max_offset.y * intensity
	)
	rotation = noise.get_noise_1d(time * 10.0 + 50.0) * max_roll * intensity

func add_trauma(amount: float) -> void:
	if not shake_enabled:
		return
	trauma = min(trauma + amount, 1.0)

func set_intensity_multiplier(v: float) -> void:
	intensity_multiplier = v

func stop_shake() -> void:
	shake_enabled = false
	trauma = 0.0
	intensity_multiplier = 0.0
	offset = Vector2.ZERO
	rotation = 0.0
