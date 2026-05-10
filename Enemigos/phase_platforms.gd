extends Node2D

@export var platform_scene: PackedScene
@export var spawn_positions: Array[Vector2] = []
@export var on_duration := 4.0
@export var off_duration := 3.0
@export var stagger := 0.7
@export var fade_dur := 0.4

var platforms: Array[Node2D] = []
var timers: Array[float] = []

func _ready():
	for i in range(spawn_positions.size()):
		if platform_scene == null:
			push_error("platform_scene no asignado en PlatformManager")
			return
		var p: Node2D = platform_scene.instantiate()
		add_child(p)
		p.position = spawn_positions[i]
		p.modulate.a = 1.0

		# One-way en el StaticBody2D, no en el CollisionShape2D
		if p is StaticBody2D:
			p.collision_layer = 1
			p.collision_mask = 0
		for child in p.get_children():
			if child is CollisionShape2D:
				child.one_way_collision = true  # solo esta línea, sin direction

		platforms.append(p)
		timers.append(-i * stagger)

	print("PlatformManager: spawneadas ", platforms.size(), " plataformas")

func _process(delta: float):
	for i in range(platforms.size()):
		timers[i] += delta
		var cycle: float = on_duration + off_duration
		var t: float = fmod(timers[i], cycle)
		if t < 0.0:
			t += cycle

		var plat: Node2D = platforms[i]
		var col: CollisionShape2D = plat.get_node_or_null("CollisionShape2D")

		if t < fade_dur:
			plat.visible = true
			plat.modulate.a = t / fade_dur
			if col:
				col.disabled = true

		elif t < on_duration - fade_dur:
			plat.visible = true
			plat.modulate.a = 1.0
			if col:
				col.disabled = false

		elif t < on_duration:
			plat.visible = true
			plat.modulate.a = 1.0 - (t - (on_duration - fade_dur)) / fade_dur
			if col:
				col.disabled = true

		else:
			plat.visible = false
			plat.modulate.a = 0.0
			if col:
				col.disabled = true

		# Multicolor
		var hue: float = fmod(timers[i] * 0.2 + i * 0.3, 1.0)
		var rainbow := Color.from_hsv(hue, 0.5, 1.0)
		rainbow.a = plat.modulate.a
		plat.modulate = rainbow
		
func stop():
	set_process(false)
	for p in platforms:
		if not is_instance_valid(p):
			continue
		p.visible = false
		p.modulate.a = 0.0
		var col: CollisionShape2D = p.get_node_or_null("CollisionShape2D")
		if col:
			col.disabled = true
