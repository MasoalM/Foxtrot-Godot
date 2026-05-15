extends Node

const AUDIO_PATHS = [
	"res://audio/",
	"res://Sounds/",
	"res://Music/"
]

var current_music = ""
var music_player: AudioStreamPlayer

var sounds = {}

var active_sounds = {}
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
					var sound_name = file_name.get_basename()
					sounds[sound_name] = stream
		file_name = directory.get_next()
	directory.list_dir_end()


# -- Music --

func play_music(sound_name: String):
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return
	
	if current_music == sound_name and music_player.playing:
		return
	
	current_music = sound_name
	
	music_player.stream = sounds[sound_name]
	music_player.volume_db = -8.0
	music_player.play()

func stop_music():
	music_player.stop()
	current_music = ""


# -- Sounds --

func play(sound_name: String, volume := 0.0, pitch := 1.0, position := Vector2.ZERO) -> void:
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return
	
	var time = Time.get_ticks_msec()
	if last_played.get(sound_name, 0) + 40 > time:
		return
	else:
		last_played[sound_name] = time
	
	var sound
	if position == Vector2.ZERO:
		sound = AudioStreamPlayer.new()
	else:
		sound = AudioStreamPlayer2D.new()
		sound.global_position = position
	
	sound.stream = sounds[sound_name]
	sound.bus = "Efectos"
	
	sound.volume_db = volume
	sound.pitch_scale = pitch
	
	add_child(sound)
	
	if not active_sounds.has(sound_name):
		active_sounds[sound_name] = []
	
	active_sounds[sound_name].append(sound)
	
	sound.finished.connect(func():
		active_sounds[sound_name].erase(sound)
		sound.queue_free()
	)
	
	sound.play()

func stop(sound_name: String) -> void:
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return
	
	if not active_sounds.has(sound_name):
		return
	
	for sound in active_sounds[sound_name]:
		if is_instance_valid(sound):
			sound.stop()
			sound.queue_free()
	
	active_sounds[sound_name].clear()


# -- Random Players --

func play_random_pitch(sound_name: String, volume := 0.0, pitch := 0.0) -> void:
	var rand_pitch := 1.0
	
	if pitch > 0.0:
		rand_pitch = randf_range(1.0 - pitch, 1.0 + pitch)
	else:
		rand_pitch = 1.0
	
	play(sound_name, volume, rand_pitch)


# -- Utils --

func get_sound(sound_name: String) -> AudioStream:
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return
	
	return sounds[sound_name]

func get_player(sound_name: String) -> AudioStreamPlayer:
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return
	
	var sound = AudioStreamPlayer.new()
	sound.stream = sounds[sound_name]
	sound.bus = "Efectos"
	
	return sound

func get_length(sound_name: String) -> float:
	if not sounds.has(sound_name):
		push_error("El sonido '" + sound_name + "' no existe.")
		return 0.0
	
	return sounds[sound_name].get_length()
