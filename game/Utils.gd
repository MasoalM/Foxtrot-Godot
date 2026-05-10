extends Node


# -- Play Time --

func format_play_time(seconds: float) -> String:
	var total := int(seconds)
	
	var days := total / 86400.0
	var hours := (total % 86400) / 3600.0
	var minutes := (total % 3600) / 60.0
	var secs := total % 60
	
	var parts := []
	
	if days >= 1.0:
		parts.append("%dd" % days)
	
	parts.append("%dh" % hours)
	parts.append("%dm" % minutes)
	parts.append("%ds" % secs)
	
	return " ".join(parts)


# -- Date --

func format_time(timestamp: int) -> String:
	var date = Time.get_datetime_dict_from_unix_time(timestamp)
	return "%02d/%02d/%d %02d:%02d" % [
		date.day,
		date.month,
		date.year,
		date.hour,
		date.minute
	]

func get_current_formatted_time() -> String:
	var date = Time.get_datetime_dict_from_system()
	return "%02d/%02d/%d %02d:%02d" % [
		date.day,
		date.month,
		date.year,
		date.hour,
		date.minute
	]

func get_current_time() -> int:
	return int(Time.get_unix_time_from_system())
