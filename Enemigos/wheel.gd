extends RigidBody2D
@export var linear_speed: float = 150.0
@export var damping: float = 0.0
@export var tamano: float = 1.0
@export_group("Rueda Enorme")
@export var rueda_enorme: bool = false
@export var romper_offset_y_min: float = -250.0
@export var romper_offset_y_max: float = 100.0
@export var velocidad_minima: float = 200.0
@export var velocidad_maxima: float = 600.0
@export var distancia_maxima: float = 1000.0

var wheel_radius
var _bounced: bool = false
var pos_y_fija: float
var _jugador: Node2D = null
var _current_speed: float

func _ready() -> void:
	pos_y_fija = global_position.y
	wheel_radius = 32.0 * tamano
	if rueda_enorme:
		mass = 99999.0
	lock_rotation = true
	for child in get_children():
		child.scale = Vector2(tamano, tamano)
	linear_damp = damping
	angular_damp = damping
	gravity_scale = 1
	contact_monitor = true
	max_contacts_reported = 4
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.0
	physics_material_override.bounce = 0.0
	_current_speed = linear_speed

func _process(_delta: float) -> void:
	if _jugador == null:
		_jugador = get_tree().get_first_node_in_group("player")
	if rueda_enorme:
		_romper_bloques()
		_matar_enemigos()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if rueda_enorme and _jugador != null:
		var distancia = global_position.distance_to(_jugador.global_position)
		var t = clampf(distancia / distancia_maxima, 0.0, 1.0)
		t = t * t
		var nueva_magnitud = lerpf(velocidad_minima, velocidad_maxima, t)
		var direccion = sign(_current_speed)
		if direccion == 0:
			direccion = 1
		_current_speed = nueva_magnitud * direccion

	if not _bounced and not rueda_enorme:
		for i in state.get_contact_count():
			var normal := state.get_contact_local_normal(i)
			if absf(normal.x) > 0.5:
				_current_speed = -_current_speed
				_bounced = true
				break
	else:
		_bounced = false

	if rueda_enorme:
		state.linear_velocity = Vector2(_current_speed, 0.0)
		var t = state.transform
		t.origin.y = pos_y_fija
		state.transform = t
	else:
		var vy = state.linear_velocity.y
		state.linear_velocity = Vector2(_current_speed, vy)

	state.angular_velocity = _current_speed / wheel_radius

func _spawn_particulas_bloque(pos_mundial: Vector2) -> void:
	var particulas := GPUParticles2D.new()
	get_tree().current_scene.add_child(particulas)
	particulas.global_position = pos_mundial

	var material := ParticleProcessMaterial.new()

	material.direction = Vector3(0, -1, 0)
	material.spread = 60.0
	material.initial_velocity_min = 80.0
	material.initial_velocity_max = 200.0
	material.gravity = Vector3(0, 500, 0)

	# Tamaño reducido
	material.scale_min = 1.0
	material.scale_max = 3.0

	material.color = Color(0.8, 0.8, 0.8, 1.0)

	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.762, 0.762, 0.762, 1.0))
	gradient.set_color(1, Color(0.589, 0.589, 0.589, 0.0))
	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = gradient
	material.color_ramp = color_ramp

	particulas.process_material = material

	# Textura más pequeña
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	particulas.texture = ImageTexture.create_from_image(image)

	particulas.amount = 12
	particulas.lifetime = 0.6
	particulas.explosiveness = 1.0
	particulas.one_shot = true
	particulas.emitting = true

	var timer := get_tree().create_timer(particulas.lifetime + 0.1)
	timer.timeout.connect(particulas.queue_free)

func _romper_bloques() -> void:
	var dir_x = sign(_current_speed)
	for tilemap in get_tree().get_nodes_in_group("tilemap"):
		var check_x = global_position + Vector2(dir_x * ((5*wheel_radius)/6) - 32, 0)
		var cell_centro = tilemap.local_to_map(tilemap.to_local(check_x))
		var cell_min = tilemap.local_to_map(tilemap.to_local(global_position + Vector2(dir_x * (((5*wheel_radius)/6) - 32), romper_offset_y_min)))
		var cell_max = tilemap.local_to_map(tilemap.to_local(global_position + Vector2(dir_x * (((5*wheel_radius)/6) - 32), romper_offset_y_max)))
		for cell_y in range(cell_min.y, cell_max.y + 1):
			var cell = Vector2i(cell_centro.x, cell_y)
			var pos_bloque = tilemap.to_global(tilemap.map_to_local(cell))
			if tilemap.get_cell_tile_data(0, cell):
				AudioManager.play("back_click", 2.0, 0.7, global_position)
				tilemap.erase_cell(0, cell)
				_spawn_particulas_bloque(pos_bloque)
			if tilemap.get_cell_tile_data(1, cell):
				AudioManager.play("back_click", 2.0, 0.7, global_position)
				tilemap.erase_cell(1, cell)
				_spawn_particulas_bloque(pos_bloque)

func _matar_enemigos() -> void:
	var dir_x = sign(_current_speed)
	for enemy in get_tree().get_nodes_in_group("Enemigos"):
		var diff = enemy.global_position - global_position
		if sign(diff.x) == dir_x and abs(diff.x) < wheel_radius and abs(diff.y) < ((5*wheel_radius)/6) - 32:
			if enemy.has_method("_muerte_instantanea"):
				enemy._muerte_instantanea()
			else:
				enemy.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("_muerte_instantanea") and rueda_enorme:
		body._muerte_instantanea()
