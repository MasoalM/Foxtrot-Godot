extends TextureRect

@onready var modo = $Modo
@onready var resolucion = $"Resolución"

var selected_resolution : int = -1

var default_size = DisplayServer.screen_get_size()
var default_screen_size = str(default_size.x) + "x" + str(default_size.y) + "p"

func _ready() -> void:
	var fullscreen = SettingsManager.get_setting("video", "fullscreen")
	var resolution = SettingsManager.get_setting("video", "resolution")
	
	for i in resolucion.item_count:
		var res = get_vector_of_resolution(i)
		
		if res == resolution:
			resolucion.selected = i
			selected_resolution = i
	
	if fullscreen:
		modo.selected = 0
		resolucion.selected = get_id_of_resolution(default_screen_size)
		resolucion.disabled = true
	else:
		modo.selected = 1
		resolucion.disabled = false
	

func _on_modo_item_selected(index: int) -> void:
	if index == 0:
		SettingsManager.save_setting("video", "fullscreen", true)
		resolucion.disabled = true
		resolucion.selected = get_id_of_resolution(default_screen_size)
	else:
		SettingsManager.save_setting("video", "fullscreen", false)
		resolucion.disabled = false
		resolucion.selected = selected_resolution
	
	SettingsManager.apply_settings()

func _on_resolución_item_selected(index: int) -> void:
	selected_resolution = index
	var res_final = get_vector_of_resolution(index)
	
	SettingsManager.save_setting("video", "resolution", res_final)
	SettingsManager.apply_settings()

# -- Helper methods -- 

func get_vector_of_resolution(index: int) -> Vector2i:
	var res = resolucion.get_item_text(index).replace("p", "").split("x")
	return Vector2i(int(res[0]), int(res[1]))

func get_id_of_resolution(res: String) -> int:
	var found_id : int = -1
	
	for i in resolucion.item_count:
		if resolucion.get_item_text(i) == res:
			found_id = i
			break
	
	return found_id
