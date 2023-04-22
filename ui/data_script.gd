extends Control


onready var red_progress = $BarContainer/RedProgress
onready var blue_progress = $BarContainer/BlueProgress
onready var yellow_progress = $BarContainer/YellowProgress


func color_up(value:int, color_index:int) -> void:
	match color_index:
		Rune.COLOR.RED:
			red_progress.add_points(value)
		Rune.COLOR.YELLOW:
			yellow_progress.add_points(value)
		Rune.COLOR.BLUE:
			blue_progress.add_points(value)
		_:
			push_error("Invalid color_index in color_up() call")
