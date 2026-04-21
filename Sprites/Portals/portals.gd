extends Node2D

@export var escena_destino: String = ""
var jugador_dentro = false

# Referencia al Sprite2D que mostrará la "F"
@onready var indicador: Sprite2D = $Indicador
@onready var portalSound = $AudioStreamPlayer2D
@onready var prePortalSound = $PrePortal
@onready var luz = $PointLight2D

func _ready() -> void:
	indicador.visible = false  # Oculto al inicio

func _process(_delta: float) -> void:
	if jugador_dentro and Input.is_action_just_pressed("enter_portal"):
		luz.energy = 15.0
		entrar_al_nivel()

func entrar_al_nivel():
	if escena_destino == "":
		print("Error: escena_destino no asignada")
		return
	jugador_dentro = false  # evita que se pueda pulsar F de nuevo
	print("Entrando al nivel: ", escena_destino)
	prePortalSound.stop()
	portalSound.play()
	var jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		jugador.bloquearControles = true
		jugador.velocity.x = 0
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(escena_destino)

func _on_area_2d_body_entered(body):
	print("body entró: ", body.name)
	if body.is_in_group("player"):
		jugador_dentro = true
		indicador.visible = true  # Mostrar imagen
		prePortalSound.play()
		luz.energy = 4.0

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		jugador_dentro = false
		indicador.visible = false  # Ocultar imagen
		prePortalSound.stop()
		luz.energy = 2.0 
