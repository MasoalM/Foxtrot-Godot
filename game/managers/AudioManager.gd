extends Node

const AUDIO_PATHS = [
	"res://audio/",
    "res://Sounds/"
]

var sounds = {}
var last_played = {}

func _ready():
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
		if directory.current_is_dir():
			if file_name != "." and file_name != "..":
				_load_ui_sounds(path + file_name + "/")
		else:
			if file_name.ends_with(".ogg"):
				var final_path = path + file_name

				var sound = AudioStreamPlayer.new()
				var stream = load(final_path)
				sound.stream = stream
				sound.bus = "Efectos"
				add_child(sound)

				var sound_name = file_name.get_basename()
				sounds[sound_name] = sound
		file_name = directory.get_next()
	directory.list_dir_end()

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
