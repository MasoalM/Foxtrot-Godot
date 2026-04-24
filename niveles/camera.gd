extends Camera2D

@export var offset_x := 400

func _process(delta):
	var target_pos = get_parent().global_position
	target_pos.x += offset_x
	
	global_position = target_pos.round()
