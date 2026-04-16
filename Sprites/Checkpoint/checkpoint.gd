extends Area2D

@onready var respawn_point = $Respawnpoint
var activado = false

func _on_body_entered(body):
	if body.is_in_group("player") and not activado:
		activado = true
		
		GameState.checkpoint_position = respawn_point.global_position
		GameState.checkpoint_activo = true
		
		print("Checkpoint activado")
