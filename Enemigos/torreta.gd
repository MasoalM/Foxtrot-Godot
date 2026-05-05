extends RigidBody2D

const proyectil = preload("res://Proyectiles/proyectil.tscn")
@onready var shotSound = $AudioStreamPlayer2DShot

const shootCooldown = 100
var shootTime = shootCooldown
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shootTime==0:
		var shoot = proyectil.instantiate()
		#shotSound.play()
		get_parent().add_child(shoot)
		shoot.position = $Marker2D.global_position
		shoot.scale.x *= -1
		shoot.vel_bala *= -1
		shootTime=shootCooldown
	else:
		shootTime-=1
