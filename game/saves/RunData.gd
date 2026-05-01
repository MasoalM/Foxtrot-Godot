extends Resource
class_name RunData

var level := 0
var collectibles := [false, false, false]

func setup(level_index: int):
	level = level_index

func collect(collectible_index: int):
	if collectible_index >= 0 and collectible_index < collectibles.size():
		collectibles[collectible_index] = true

func reset():
	level = 0
	collectibles.fill(false)
