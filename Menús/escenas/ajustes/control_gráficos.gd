extends TextureRect

@onready var modo: OptionButton = $Modo
@onready var resolucion: OptionButton = $"Resolución"

var selected_resolution : int = -1

func _ready() -> void:
	refresh()

func refresh():
	var data = SettingsManager.data
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	
	if data.fullscreen:
		data.resolution = Vector2i(screen_size.x, screen_size.y)
		
		modo.selected = 0
		resolucion.disabled = true
	else:
		modo.selected = 1
		resolucion.disabled = false
	
	for i in resolucion.item_count:
		var res = get_vector_of_resolution(i)
		
		if res.x > screen_size.x or res.y > screen_size.y:
			resolucion.set_item_disabled(i, true)
		
		if res == data.resolution:
			resolucion.selected = i
			selected_resolution = i


# -- Selectors --

func _on_modo_item_selected(index: int) -> void:
	var data = SettingsManager.data
	
	if index == 0:
		data.fullscreen = true
		data.resolution = DisplayServer.screen_get_size()
		
		resolucion.disabled = true
		
		for i in resolucion.item_count:
			if get_vector_of_resolution(i) == data.resolution:
				resolucion.selected = i
				break
	else:
		data.fullscreen = false
		data.resolution = data.windowed_resolution
		
		resolucion.disabled = false
		
		for i in resolucion.item_count:
			if get_vector_of_resolution(i) == data.windowed_resolution:
				resolucion.selected = i
				break
	
	SettingsManager.apply_settings()
	SettingsManager.save_from_data()

func _on_resolución_item_selected(index: int) -> void:
	var data = SettingsManager.data
	var res_final = get_vector_of_resolution(index)
	
	selected_resolution = index
	
	data.windowed_resolution = res_final
	
	if not data.fullscreen:
		data.resolution = res_final
	
	SettingsManager.apply_settings()
	SettingsManager.save_from_data()


# -- Helper methods -- 

func get_vector_of_resolution(index: int) -> Vector2i:
	var res = resolucion.get_item_text(index).replace("p", "").split("x")
	return Vector2i(int(res[0]), int(res[1]))

func get_id_of_resolution(res: String) -> int:
	for i in resolucion.item_count:
		if resolucion.get_item_text(i) == res:
			return i
	
	return -1
