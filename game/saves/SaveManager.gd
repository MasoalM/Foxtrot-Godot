extends Node

var save_data: SaveData
var run_data: RunData

var session_start_time: float = 0.0
var current_slot := ""


# -- Creating, Saving, Loading and Delete --

func create_game(slot: String, title: String):
	current_slot = slot
	
	save_data = SaveData.new()
	save_data.title = title
	save_data.last_time_played = Utils.get_current_time()
	print("Partida creada: %s" % current_slot)
	
	run_data = null

func save_game(save_playtime: bool = true):
	if save_data == null or current_slot.is_empty():
		push_error("No se ha podido guardar la partida.")
		return
	
	if save_playtime:
		save_data.play_time += (Utils.get_current_time() - session_start_time)
	save_data.last_time_played = Utils.get_current_time()
	ResourceSaver.save(save_data, _get_path(current_slot))
	print("Partida guardada: %s" % current_slot)

func save_ingame():
	if save_data == null or current_slot.is_empty():
		push_error("No se ha podido guardar la partida.")
		return
	
	save_data.play_time += (Utils.get_current_time() - session_start_time)
	save_data.last_time_played = Utils.get_current_time()
	save_data.lives = GameState.vidas_juego
	save_data.score += GameState.puntuacion
	save_data.level_completed = GameState.nivel
	save_data.collectibles[(GameState.nivel - 1)] = GameState.monedas_estado
	
	ResourceSaver.save(save_data, _get_path(current_slot))
	print("Partida guardada en juego: %s" % current_slot)

func load_game(slot: String):
	var save_path = _get_path(slot)
	
	if not _exists(slot):
		push_error("La partida %s no existe." % slot)
		return
	
	current_slot = slot
	session_start_time = Utils.get_current_time()
	
	save_data = ResourceLoader.load(save_path)
	print("Partida cargada: %s" % current_slot)
	
	run_data = null

func delete_game():
	DirAccess.remove_absolute(_get_path(current_slot))
	print("Partida eliminada: %s" % current_slot)


# -- Game Management --

func start_level(level: int):
	run_data = RunData.new()
	run_data.setup(level)

func mark_collected(collectible_index: int):
	if run_data == null:
		push_error("El nivel no existe.")
		return
	
	run_data.collect(collectible_index)

func complete_level():
	if run_data == null:
		push_error("El nivel no existe.")
		return
	
	var level = run_data.level
	
	for i in run_data.collectibles.size():
		save_data.collected(level, i)
	
	if level == save_data.level_completed:
		save_data.level_completed += 1
	
	save_game()
	run_data = null

func fail_level():
	if run_data == null:
		push_error("El nivel no existe.")
		return
	
	run_data = null

# -- Utilities --

func _exists(slot: String) -> bool:
	return FileAccess.file_exists(_get_path(slot))

func _exists_any() -> bool:
	var slots = ["A", "B", "C"]
	
	for slot in slots:
		if _exists(slot):
			return true
	
	return false

func _get_path(slot: String) -> String:
	return "user://save_slot_%s.tres" % slot

# -- Partida Helpers --

func set_info(label: Label, value: String):
	var info: String = label.text.split(":")[0] + ": "
	label.text = info + value

func get_slot_texture(slot: String, selected: bool) -> Texture2D:
	var path: String = "res://Menús/assets/slots/"
	var type: String = "Default.png"
	
	if SaveManager._exists(slot):
		type = "%s.png" % slot
	
	if selected:
		type = type.replace(".png", " Selected.png")
	
	return load(path + type)
