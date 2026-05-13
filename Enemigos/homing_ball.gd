extends Area2D

@export var speed := 250.0
@export var turn_speed := 2.0
@export var lifetime := 5.0
var velocity := Vector2.ZERO
var target: Node2D = null
var shooter: Node2D = null
var _lifetime_timer := 0.0
var _dead := false

func _ready():
	add_to_group("EnemyBall")
	add_to_group("Enemigos")
	add_to_group("OwlBossBall")
	
	collision_layer = 4
	#collision_mask = 2
	#collision_layer = 1
	collision_mask = 3
	monitoring = true
	monitorable = true
	
	body_entered.connect(_on_body_hit)
	area_entered.connect(_on_area_hit)

func _physics_process(delta):
	if _dead:
		return
	
	_lifetime_timer += delta
	if _lifetime_timer >= lifetime:
		_morir()
		return
	
	# Detección manual de proyectiles aliados por proximidad
	for bala in get_tree().get_nodes_in_group("ProyectilAliado"):
		if is_instance_valid(bala):
			if global_position.distance_to(bala.global_position) < 30.0:
				bala.morir()
				_morir()
				return
	
	if target == null or not is_instance_valid(target):
		position += velocity * delta
		return
	
	var desired_direction := (target.global_position - global_position).normalized()
	var current_direction := velocity.normalized()
	var new_direction := current_direction.lerp(desired_direction, turn_speed * delta).normalized()
	
	velocity = new_direction * speed
	position += velocity * delta
	
	if velocity.length() > 0.1:
		rotation = velocity.angle()

func _on_body_hit(body):
	if _dead:
		return
	if body == shooter:
		return
	if body.is_in_group("player"):
		if body.has_method("_dañar"):
			body._dañar()
		_morir()
		return
	if body is TileMapLayer or body is TileMap:
		_morir()

func _on_area_hit(area: Area2D):
	if _dead:
		return
	
	if area.is_in_group("ProyectilAliado"):
		area.morir()
		_morir()
		return
	
	var parent = area.get_parent()
	if parent == shooter:
		return
	
	if area.is_in_group("player") or parent.is_in_group("player"):
		var p = area if area.is_in_group("player") else parent
		if p.has_method("_dañar"):
			p._dañar()
		_morir()

func _morir():
	if _dead:
		return
		
	_dead = true
	visible = false
	
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	queue_free()

func set_direction_from_target(target_node):
	if not is_instance_valid(target_node):
		return
	
	var dir = sign(target_node.global_position.x - global_position.x)
	if dir == 0:
		dir = 1
	velocity = Vector2(dir, 0) * speed

func set_target(t):
	target = t

func set_shooter(s):
	shooter = s
