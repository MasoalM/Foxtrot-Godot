extends Node

const AUDIO_PATHS = [
	"res://audio/",
	"res://Sounds/",
	"res://Music/"
]

const PRELOAD_SOUNDS = {
	"BOSS": preload("res://Music/BOSS.ogg"),
	"BossFightAntigua": preload("res://Music/BossFightAntigua.ogg"),
	"DeathScreen": preload("res://Music/DeathScreen.ogg"),
	"GameEnding": preload("res://Music/GameEnding.ogg"),
	"Level1": preload("res://Music/Level1.ogg"),
	"Level2": preload("res://Music/Level2.ogg"),
	"Level3": preload("res://Music/Level3.ogg"),
	"Level4": preload("res://Music/Level4.ogg"),
	"Level5": preload("res://Music/Level5.ogg"),
	"LevelsMenu": preload("res://Music/LevelsMenu.ogg"),
	"MenuPrincipal": preload("res://Music/MenuPrincipal.ogg"),
	"26": preload("res://audio/ui/26.ogg"),
	"27": preload("res://audio/ui/27.ogg"),
	"back_click": preload("res://audio/ui/back_click.ogg"),
	"click": preload("res://audio/ui/click.ogg"),
	"close_game": preload("res://audio/ui/close_game.ogg"),
	"error": preload("res://audio/ui/error.ogg"),
	"hover_button": preload("res://audio/ui/hover_button.ogg"),
	"menu_principal_click": preload("res://audio/ui/menu_principal_click.ogg"),
	"BrokenWoodBlock": preload("res://Sounds/BrokenWoodBlock.ogg"),
	"1UP": preload("res://Sounds/1UP.ogg"),
	"CheckPoint": preload("res://Sounds/CheckPoint.ogg"),
	"Coin": preload("res://Sounds/Coin.ogg"),
	"DoubleJumpPowerUp": preload("res://Sounds/DoubleJumpPowerUp.ogg"),
	"FirePowerUp": preload("res://Sounds/FirePowerUp.ogg"),
	"Freeze": preload("res://Sounds/Freeze.ogg"),
	"geiser": preload("res://Sounds/geiser.ogg"),
	"HawkerShot": preload("res://Sounds/HawrkerShot.ogg"),
	"HealPowerUp": preload("res://Sounds/HealPowerUp.ogg"),
	"IcePowerUp": preload("res://Sounds/IcePowerUp.ogg"),
	"MadBoss": preload("res://Sounds/MadBoss.ogg"),
	"MadMox": preload("res://Sounds/MadMox.ogg"),
	"NoTime": preload("res://Sounds/NoTime.ogg"),
	"Portal": preload("res://Sounds/Portal.ogg"),
	"ShieldPowerUp": preload("res://Sounds/ShieldPowerUp.ogg"),
	"ShotImpact": preload("res://Sounds/ShotImpact.ogg"),
	"SorceravenShot": preload("res://Sounds/SorceravenShot.ogg"),
	"Walk": preload("res://Sounds/Walk.ogg"),
	"Water1": preload("res://Sounds/Water1.ogg")
}

var current_music = ""
var music_player: AudioStreamPlayer

var sounds = {}
var last_played = {}

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Música"
	add_child(music_player)
	for sound_name in PRELOAD_SOUNDS:
		if not sounds.has(sound_name):
			var sound = AudioStreamPlayer.new()
			sound.stream = PRELOAD_SOUNDS[sound_name]
			sound.bus = "Efectos"
			add_child(sound)

			sounds[sound_name] = sound
	
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
