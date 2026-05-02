extends Camera2D

@export var offset_x := 400

func _ready():
	adjust_camera()

func _process(_delta):
	adjust_camera()

func adjust_camera():
	var target_pos = get_parent().global_position
	target_pos.x += offset_x
	
	global_position = target_pos.round()
