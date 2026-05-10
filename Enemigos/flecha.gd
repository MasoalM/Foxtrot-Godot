extends Area2D

@export var speed := 400
@export var gravity_force := 900 

var velocity = Vector2.ZERO
var shooter = null

func _physics_process(delta):
	# aplicar gravedad
	velocity.y += gravity_force * delta
	
	# mover proyectil
	position += velocity * delta
	
	# rotar hacia la dirección del movimiento
	rotation = velocity.angle() + deg_to_rad(90)

func shoot_to_target(target_pos):
	var time = clamp(global_position.distance_to(target_pos) / 300.0, 0.5, 1.5)
	var displacement = target_pos - global_position
	
	velocity.x = displacement.x / time
	velocity.y = (displacement.y / time) - (0.5 * gravity_force * time)

func _on_body_entered(body):
	if body == shooter:
		return
	
	if body.is_in_group("player"):
		if body.has_method("_dañar"):
			body._dañar()
		
		queue_free()
	
	if body is TileMap:
		var tilemap = body
		
		var offset = Vector2(0, 32)
		if velocity.y < 0:
			offset = Vector2(0, -32)
		
		var pos = tilemap.to_local(global_position + offset)
		var cell = tilemap.local_to_map(pos)
		
		var tile_data = tilemap.get_cell_tile_data(0, cell)
		
		if tile_data == null:
			queue_free()
			return
		
		var pass_through: bool = false
		if tile_data.has_custom_data("pass_through"):
			pass_through = tile_data.get_custom_data("pass_through")
		
		if not pass_through:
			queue_free()
