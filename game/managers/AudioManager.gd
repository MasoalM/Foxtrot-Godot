extends Node

const AUDIO_PATHS = [
	"res://audio/",
	"res://Sounds/",
	"res://Music/"
]

var current_music = ""
var music_player: AudioStreamPlayer

var sounds = {}
var last_played = {}

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Música"
	add_child(music_player)
	
	for path in AUDIO_PATHS:
		_load_ui_sounds(path)

func _load_ui_sounds(path: String):
	var directory = DirAccess.open(path)
	if directory == null:
		push_error("La carpeta %s no se ha encontrado" % path)
		return
	
	directory.list_dir_begin()
	
	var file_name = directory.get_next()
	while file_name != "":
		if file_name.ends_with(".import"):
			file_name = file_name.replace(".import", "")
		
		if directory.current_is_dir():
			if file_name != "." and file_name != "..":
				_load_ui_sounds(path + file_name + "/")
		else:
			if file_name.ends_with(".ogg"):
				var final_path = path + file_name
				
				var stream = ResourceLoader.load(final_path)
				if stream:
					var sound = AudioStreamPlayer.new()
					sound.stream = stream
					sound.bus = "Efectos"
					add_child(sound)
				
					var sound_name = file_name.get_basename()
					sounds[sound_name] = sound
		file_name = directory.get_next()
	directory.list_dir_end()


# -- Music --

func play_music(sound_name):
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return
	
	if current_music == sound_name and music_player.playing:
		return
	
	current_music = sound_name
	
	music_player.stream = sounds[sound_name].stream
	music_player.volume_db = -8.0
	music_player.play()

func stop_music():
	music_player.stop()
	current_music = ""


# -- Sounds --

func play(sound_name, pitch := 0.0) -> void:
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return
	
	var sound = sounds[sound_name]
	var time = Time.get_ticks_msec()
	
	if last_played.get(sound_name, 0) + 40 > time:
		return
	
	last_played[sound_name] = time
	
	if pitch > 0.0:
		sound.pitch_scale = randf_range(1.0 - pitch, 1.0 + pitch)
	else:
		sound.pitch_scale = 1.0
	
	sound.play()


# -- Utils --

func get_sound(sound_name) -> AudioStreamPlayer:
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return
	
	return sounds.get(sound_name)
