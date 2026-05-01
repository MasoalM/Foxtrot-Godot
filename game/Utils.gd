extends Node

# -- Play Time --

func format_play_time(seconds: int) -> String:
	var days := seconds / 86400.0
	var hours := (seconds % 86400) / 3600.0
	var minutes := (seconds % 3600) / 60.0
	var secs := seconds % 60
	
	var parts := []
	
	if days > 0:
		parts.append("%dd" % days)
	if hours > 0:
		parts.append("%dh" % hours)
	if minutes > 0:
		parts.append("%dm" % minutes)
	if secs > 0 or parts.is_empty():
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
