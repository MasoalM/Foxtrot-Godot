extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ataqueCargado")
	add_to_group("ProyectilAliado")
	await get_tree().create_timer(0.2).timeout
	queue_free()
	
func _on_body_entered(body):
	if body is TileMap:
		var tilemap = body
		
		var shape_node = $CollisionShape2D
		var shape = shape_node.shape
		
		if shape is RectangleShape2D:
			var extents = shape.extents
			
			var step = 64
			
			for x in range(-extents.x, extents.x, step):
				for y in range(-extents.y, extents.y, step):
					
					var world_pos = global_position + Vector2(x, y)
					var local_pos = tilemap.to_local(world_pos)
					var cell = tilemap.local_to_map(local_pos)
					
					var tile_data = tilemap.get_cell_tile_data(0, cell)
					
					if tile_data and tile_data.get_custom_data("destructible"):
						tilemap.erase_cell(0, cell)
