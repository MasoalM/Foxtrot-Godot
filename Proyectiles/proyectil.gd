extends Area2D

const dist_max = 45.0

var vel_bala = 600.0
var dist = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ProyectilAliado")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += vel_bala * delta
	dist += 1
	if dist > dist_max:
		morir()
	
func morir():
	remove_from_group("ProyectilAliado")
	queue_free()
	
func _on_body_entered(body):
	print("colision con:", body)

	if body is TileMap:
		var tilemap = body
		
		var offset = Vector2(32 if vel_bala > 0 else -32, 0)
		var pos = tilemap.to_local(global_position + offset)
		var cell = tilemap.local_to_map(pos)

		print("celda:", cell)

		var tile_data = tilemap.get_cell_tile_data(0, cell)

		if tile_data == null:
			print("❌ no hay tile_data")
			return

		var destructible = tile_data.get_custom_data("destructible")
		print("destructible:", destructible)

		if destructible:
			print("💥 rompiendo bloque")
			tilemap.erase_cell(0, cell)
			morir()
