extends Node

var config = ConfigFile.new()
var configPath = "user://settings.cfg"

func _ready():
	load_settings()
	apply_settings()

# -- Save & Load --

func load_settings():
	var load_error : Error = config.load(configPath)
	
	if load_error != Error.OK:
		print("Settins not loaded. Creating file...")
		create_default_settings()
		save()
	else:
		print("Settings loaded!")

func save_setting(section, key, value):
	config.set_value(section, key, value)
	save()

func save():
	config.save(configPath)

func get_setting(section, key, value = null):
	return config.get_value(section, key, value)

# -- Default Loader -- 
func create_default_settings():
	var screen_size = DisplayServer.screen_get_size()
	
	# -- Audio Settings --
	config.set_value("audio", "musica", 1.0)
	config.set_value("audio", "efectos", 1.0)
	
	# -- Video Settings --
	config.set_value("video", "fullscreen", true)
	config.set_value("video", "resolution", Vector2i(screen_size.x, screen_size.y))
	
	print("Default config file created!")

# -- Apply --
func apply_settings():
	_apply_audio()
	_apply_video()

func _apply_audio():
	var musica_vol : float = get_setting("audio", "musica")
	var efectos_vol : float = get_setting("audio", "efectos")
	
	var musica_bus : int = AudioServer.get_bus_index("Música")
	var efectos_bus : int = AudioServer.get_bus_index("Efectos")
	
	AudioServer.set_bus_volume_db(musica_bus, linear_to_db(musica_vol))
	AudioServer.set_bus_volume_db(efectos_bus, linear_to_db(efectos_vol))

func _apply_video():
	var fullscreen = get_setting("video", "fullscreen")
	var resolution = get_setting("video", "resolution")
	
	DisplayServer.window_set_size(resolution)
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
