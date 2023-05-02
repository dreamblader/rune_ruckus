extends Control


onready var preview_runes = $PreviewPanel
onready var red_progress = $BarContainer/RedProgress
onready var blue_progress = $BarContainer/BlueProgress
onready var yellow_progress = $BarContainer/YellowProgress
onready var green_progress = $BarContainer/GreenProgress
onready var purple_progress = $BarContainer/PurpleProgress
onready var orange_progress = $BarContainer/OrangeProgress

onready var score = $ScoreContainer/Score
onready var highscore = $ScoreContainer/HighScore

signal bar_complete(color)

func color_up(value:int, color_index:int) -> void:
	match color_index:
		Rune.COLOR.RED:
			red_progress.add_points(value)
		Rune.COLOR.YELLOW:
			yellow_progress.add_points(value)
		Rune.COLOR.BLUE:
			blue_progress.add_points(value)
		Rune.COLOR.GREEN:
			green_progress.add_points(value)
		Rune.COLOR.PURPLE:
			purple_progress.add_points(value)
		Rune.COLOR.ORANGE:
			orange_progress.add_points(value)
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
		Rune.COLOR.GREEN:
			return green_progress.rect_global_position
		Rune.COLOR.PURPLE:
			return purple_progress.rect_global_position
		Rune.COLOR.ORANGE:
			return orange_progress.rect_global_position
		_:
			push_error("Invalid color_index in get_bar_position() call")
			return Vector2()


func unlock_color_bar(color_index:int) -> void:
	match color_index:
		Rune.COLOR.GREEN:
			green_progress.visible = true
		Rune.COLOR.PURPLE:
			purple_progress.visible = true
		Rune.COLOR.ORANGE:
			orange_progress.visible = true


func set_preview(next_preview_runes_color:Array) -> void:
	preview_runes.set_preview(next_preview_runes_color)


func set_score(value:String) -> void:
	score.set_text(value)


func set_highscore(value:String) -> void:
	highscore.set_text(value)


func _on_RedProgress_bar_complete() -> void:
	_on_color_bar_complete(Rune.COLOR.RED)


func _on_BlueProgress_bar_complete() -> void:
	_on_color_bar_complete(Rune.COLOR.BLUE)


func _on_YellowProgress_bar_complete() -> void:
	_on_color_bar_complete(Rune.COLOR.YELLOW)


func _on_OrangeProgress_bar_complete() -> void:
	_on_color_bar_complete(Rune.COLOR.ORANGE)


func _on_GreenProgress_bar_complete() -> void:
	_on_color_bar_complete(Rune.COLOR.GREEN)


func _on_PurpleProgress_bar_complete() -> void:
	_on_color_bar_complete(Rune.COLOR.PURPLE)


func _on_color_bar_complete(color_index) -> void:
	emit_signal("bar_complete", color_index)
