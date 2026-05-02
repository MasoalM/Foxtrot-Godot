extends Area2D

@onready var respawn_point = $Respawnpoint
@onready var sound = $AudioCheckpoint
@onready var light = $PointLight2D
@onready var particles = $GPUParticles2D

var activado = false

func _on_body_entered(body):
	if body.is_in_group("player") and not activado:
		activado = true
		GameState.checkpoint_position = respawn_point.global_position
		GameState.checkpoint_activo = true
		GameState.checkpoint_tiempo = 121
		sound.play()
		light.energy = 6
		particles.amount = 300
		await get_tree().create_timer(1.25).timeout
		light.energy = 3
		particles.amount = 150
