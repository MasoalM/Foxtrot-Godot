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
	# ── Velocidad dinámica por distancia (solo rueda enorme) ─────
	if rueda_enorme and _jugador != null:
		var distancia = global_position.distance_to(_jugador.global_position)
		var t = clampf(distancia / distancia_maxima, 0.0, 1.0)
		t = t * t
		var nueva_magnitud = lerpf(velocidad_minima, velocidad_maxima, t)
		var direccion = sign(_current_speed)
		if direccion == 0:
			direccion = 1
		_current_speed = nueva_magnitud * direccion

	# ── Detección de pared ───────────────────────────────────────
	if not _bounced and not rueda_enorme:
		for i in state.get_contact_count():
			var normal := state.get_contact_local_normal(i)
			if absf(normal.x) > 0.5:
				_current_speed = -_current_speed
				_bounced = true
				break
	else:
		_bounced = false

	# ── Movimiento ───────────────────────────────────────────────
	if rueda_enorme:
		state.linear_velocity = Vector2(_current_speed, 0.0)
		var t = state.transform
		t.origin.y = pos_y_fija
		state.transform = t
	else:
		var vy = state.linear_velocity.y
		state.linear_velocity = Vector2(_current_speed, vy)

	state.angular_velocity = _current_speed / wheel_radius

func _romper_bloques() -> void:
	var dir_x = sign(_current_speed)
	for tilemap in get_tree().get_nodes_in_group("tilemap"):
		var check_x = global_position + Vector2(dir_x * ((5*wheel_radius)/6) - 32, 0)
		var cell_centro = tilemap.local_to_map(tilemap.to_local(check_x))
		var cell_min = tilemap.local_to_map(tilemap.to_local(global_position + Vector2(dir_x * (((5*wheel_radius)/6) - 32), romper_offset_y_min)))
		var cell_max = tilemap.local_to_map(tilemap.to_local(global_position + Vector2(dir_x * (((5*wheel_radius)/6) - 32), romper_offset_y_max)))
		for cell_y in range(cell_min.y, cell_max.y + 1):
			var cell = Vector2i(cell_centro.x, cell_y)
			if tilemap.get_cell_tile_data(0, cell):
				tilemap.erase_cell(0, cell)
			if tilemap.get_cell_tile_data(1, cell):
				tilemap.erase_cell(1, cell)

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
