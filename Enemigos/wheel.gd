extends RigidBody2D

@export var linear_speed: float = 150.0
@export var damping: float = 0.0
@export var tamano: float = 1.0

var wheel_radius

# Evita que el rebote se dispare varias veces seguidas
var _bounced: bool = false

func _ready() -> void:
	wheel_radius = 32.0 * tamano
	
	# Escala para la forma de colisión
	for child in get_children():
		child.scale = Vector2(tamano, tamano)
	
	linear_damp = damping
	angular_damp = damping
	gravity_scale = 20
	contact_monitor = true
	max_contacts_reported = 4
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.0
	physics_material_override.bounce = 0.0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
		# ── Detección de pared ───────────────────────────────────────
	
	if not _bounced:
		for i in state.get_contact_count():
			var normal := state.get_contact_local_normal(i)
			if absf(normal.x) > 0.5:
				linear_speed = -linear_speed
				_bounced = true   # bloquea hasta el próximo frame
				break
	else:
		_bounced = false   # un frame de cooldown, luego vuelve a escuchar
	# ── Movimiento ───────────────────────────────────────────────
	state.linear_velocity = Vector2(linear_speed, 0.0)
	state.angular_velocity = linear_speed / wheel_radius
