extends Area2D

enum FrogType { GREEN, BLUE, RED }

@onready var sprite := $Sprite2D
@export var frog_type: FrogType = FrogType.GREEN

const FROG_DATA := {
	FrogType.GREEN: { "value": 1, "color": Color(0, 1, 0.0, 1.0) },
	FrogType.BLUE:  { "value": 5,  "color": Color(0.0, 0.5, 1, 1.0) },
	FrogType.RED:   { "value": 10, "color": Color(1.0, 0, 0, 1.0) },
}

var base_y := 0.0

func _ready() -> void:
	sprite.modulate = FROG_DATA[frog_type]["color"]

	base_y = position.y
	_start_floating()

func _start_floating() -> void:
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		self,
		"position:y",
		base_y - 3,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		self,
		"position:y",
		base_y + 3,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.recoger_rana(FROG_DATA[frog_type]["value"])
		_collect()

func _collect() -> void:
	set_deferred("monitoring", false)

	AudioManager.play("Coin", -7.0, 2.0, global_position)

	var tween := create_tween()

	tween.tween_property(sprite, "scale", Vector2(1.6, 1.6), 0.1)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
