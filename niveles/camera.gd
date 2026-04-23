extends Camera2D

func _process(delta):
	global_position = get_parent().global_position.round()
