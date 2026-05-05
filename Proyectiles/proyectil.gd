extends Area2D

const dist_max = 45.0

var vel_bala = 600.0
var dist = 0.0

func _ready() -> void:
	add_to_group("ProyectilAliado")

func _process(delta: float) -> void:
	if visible:
		position.x += vel_bala * delta
		dist += 1
		if dist > dist_max:
			morir()
	
func morir():
	remove_from_group("ProyectilAliado")
	queue_free()
	
func _on_body_entered(body):
	if not visible:
		return
	
	if body is TileMap:
		var tilemap = body
		
		var offset = Vector2(32 if vel_bala > 0 else -32, 0)
		var pos = tilemap.to_local(global_position + offset)
		var cell = tilemap.local_to_map(pos)
		
		var tile_data = tilemap.get_cell_tile_data(0, cell)
		
		if tile_data == null:
			cell = tilemap.local_to_map(tilemap.to_local(global_position))
			tile_data = tilemap.get_cell_tile_data(0, cell)
		
		if tile_data == null:
			morir()
			return
		
		var destructible: bool = false
		if tile_data.has_custom_data("destructible"):
			destructible = tile_data.get_custom_data("destructible")
		
		if destructible:
			AudioManager.play("BrokenWoodBlock")
			tilemap.erase_cell(0, cell)
			visible = false
			await get_tree().create_timer(0.2).timeout
			if is_instance_valid(self):
				morir()
		else:
			morir()
	else:
			morir()

func _on_area_entered(area: Area2D) -> void:
	if not visible:
		return
	if area.is_in_group("OwlBossBall"):
		area._morir()
		morir()
