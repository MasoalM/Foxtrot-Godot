extends Resource
class_name SaveData

const TOTAL_LEVELS = 5

@export var title := ""

@export var play_time := 0.0
@export var last_time_played := 0

@export var lives := 5
@export var score := 0
@export var collectibles := {}

@export var level_completed := 0

func _init():
	for i in TOTAL_LEVELS:
		collectibles[i] = [false, false, false]

# -- Collectibles --

func collected(level: int, index: int):
	level -= 1
	
	if collectibles.has(level):
		if index >= 0 and index < collectibles[level].size():
			collectibles[level][index] = true

func is_collected(level: int, index: int) -> bool:
	level -= 1
	
	if collectibles.has(level):
		if index >= 0 and index < collectibles[level].size():
			return collectibles[level][index]
	
	return false

func get_total_collected() -> int:
	var total := 0
	
	for level in collectibles.values():
		for collec in level:
			if collec:
				total += 1
	
	return total 
