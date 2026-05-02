extends Area2D

const dist_max = 135.0

var vel_bala = 300.0
var dist = 0.0
var direccion = 1

func _ready() -> void:
	add_to_group("ProyectilAliado")

func _process(delta: float) -> void:
	if visible:
		position.x += vel_bala * direccion * delta
		dist += 1
		if dist > dist_max:
			morir()

func morir():
	remove_from_group("ProyectilAliado")
	queue_free()

func _on_body_entered(body):
	if visible:
		if body is TileMap:
			var tilemap = body
			
			var offset = Vector2(32 if direccion > 0 else -32, 0)
			var pos = tilemap.to_local(global_position + offset)
			var cell = tilemap.local_to_map(pos)
			
			var tile_data = tilemap.get_cell_tile_data(0, cell)
			
			if tile_data == null:
				return
			
			var destructible: bool = false
			if tile_data.has_custom_data("destructible"):
				destructible = tile_data.get_custom_data("destructible")
			
			if destructible:
				AudioManager.play("BrokenWoodBlock")
				tilemap.erase_cell(0, cell)
				visible = false
				await get_tree().create_timer(0.2).timeout
				morir()
			else:
				morir()

func set_direccion(dir):
	direccion = dir
	
	# Girar sprite correctamente
	$Sprite2D.flip_h = direccion < 0
