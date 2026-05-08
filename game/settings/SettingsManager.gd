extends Node

var config = ConfigFile.new()
var configPath = "user://settings.cfg"

var data := SettingsData.new()

func _ready():
	load_settings()
	apply_settings()

# -- Save & Load --

func load_settings():
	var load_error: Error = config.load(configPath)
	
	if load_error != Error.OK:
		print("Settins not found. Creating file...")
		create_default_settings()
		save_from_data()
	else:
		load_from_data()

func save_from_data():
	config.set_value("audio", "musica", data.musica)
	config.set_value("audio", "efectos", data.efectos)
	
	config.set_value("video", "fullscreen", data.fullscreen)
	config.set_value("video", "windowed_resolution", data.windowed_resolution)
	config.set_value("video", "resolution", data.resolution)
	
	save()

func save():
	config.save(configPath)

# -- Loader -- 
func create_default_settings():
	data = SettingsData.new()
	data.resolution = DisplayServer.screen_get_size()

func load_from_data():
	data.musica = config.get_value("audio", "musica")
	data.efectos = config.get_value("audio", "efectos")
	
	data.fullscreen = config.get_value("video", "fullscreen")
	data.windowed_resolution = config.get_value("video", "windowed_resolution")
	data.resolution = config.get_value("video", "resolution")


# -- Apply --
func apply_settings():
	_apply_audio()
	_apply_video()

func _apply_audio():
	var musica_bus = AudioServer.get_bus_index("Música")
	var efectos_bus = AudioServer.get_bus_index("Efectos")
	
	AudioServer.set_bus_volume_db(musica_bus, linear_to_db(data.musica))
	AudioServer.set_bus_volume_db(efectos_bus, linear_to_db(data.efectos))

func _apply_video():
	if data.fullscreen:
		var screen_size: Vector2i = DisplayServer.screen_get_size()
		
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_size(screen_size)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(data.windowed_resolution)
		
		var screen_size: Vector2i = DisplayServer.screen_get_size()
		var window_size: Vector2i = data.windowed_resolution
		
		@warning_ignore("integer_division")
		var centered: Vector2i = Vector2i((screen_size.x - window_size.x) / 2, (screen_size.y - window_size.y) / 2)
		DisplayServer.window_set_position(centered)
