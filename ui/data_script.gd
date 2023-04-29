extends Control


onready var preview_runes = $PreviewPanel
onready var red_progress = $BarContainer/RedProgress
onready var blue_progress = $BarContainer/BlueProgress
onready var yellow_progress = $BarContainer/YellowProgress

onready var score = $ScoreContainer/Score
onready var highscore = $ScoreContainer/HighScore


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


func get_bar_position(color_index:int) -> Vector2:
	match color_index:
		Rune.COLOR.RED:
			return red_progress.rect_global_position
		Rune.COLOR.YELLOW:
			return yellow_progress.rect_global_position
		Rune.COLOR.BLUE:
			return blue_progress.rect_global_position
		_:
			push_error("Invalid color_index in get_bar_position() call")
			return Vector2()


func set_preview(next_preview_runes_color:Array) -> void:
	preview_runes.set_preview(next_preview_runes_color)


func set_score(value:String) -> void:
	score.set_text(value)


func set_highscore(value:String) -> void:
	highscore.set_text(value)
