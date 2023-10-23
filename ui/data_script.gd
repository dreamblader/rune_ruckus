extends Control


onready var preview_runes = $PreviewPanel
onready var red_progress = $BarContainer/RedProgress
onready var blue_progress = $BarContainer/BlueProgress
onready var yellow_progress = $BarContainer/YellowProgress
onready var green_progress = $BarContainer/GreenProgress
onready var purple_progress = $BarContainer/PurpleProgress
onready var orange_progress = $BarContainer/OrangeProgress

onready var spell_containter = $SpeelContainer
onready var spell_purple = $SpeelContainer/SpellBlock2
onready var spell_orange = $SpeelContainer/SpellBlock3
onready var spell_green = $SpeelContainer/SpellBlock4

onready var score = $ScoreContainer/Score
onready var highscore = $ScoreContainer/HighScore

signal bar_complete(color)

var spell_index:int = -1
var old_spell_index: int = -1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_spell_l"):
		move_spell_block(-1)
	
	if event.is_action_pressed("move_spell_r"):
		move_spell_block(1)


func reset_data() -> void:
	spell_index = -1
	old_spell_index = -1
	
	red_progress.clear()
	blue_progress.clear()
	yellow_progress.clear()
	green_progress.clear()
	purple_progress.clear()
	orange_progress.clear()
	
	green_progress.visible = false
	purple_progress.visible = false
	orange_progress.visible = false
	
	spell_purple.lock_block()
	spell_orange.lock_block()
	spell_green.lock_block()


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
			green_progress.appear()
			spell_green.unlock_block()
			set_spell_index(spell_green.get_index())
		Rune.COLOR.PURPLE:
			purple_progress.appear()
			spell_purple.unlock_block()
			set_spell_index(spell_purple.get_index())
		Rune.COLOR.ORANGE:
			orange_progress.appear()
			spell_orange.unlock_block()
			set_spell_index(spell_orange.get_index())
	
	select_spell_block()


func set_spell_index(value:int) -> void:
	old_spell_index = spell_index
	spell_index = value


func move_spell_block(value:int) -> void:
	if spell_index >= 0:
		var new_index = spell_index_change(spell_index, value)
		
		while spell_containter.get_child(new_index).my_symbol < 0:
			new_index = spell_index_change(new_index, value)
		
		set_spell_index(new_index)
		select_spell_block()


func spell_index_change(index:int, value:int) -> int:
	var new_index = (index + value) % spell_containter.get_child_count()
	if new_index < 0:
		new_index = spell_containter.get_child_count() - 1
	return new_index


func select_spell_block() -> void:
	var unselected_block = spell_containter.get_child(old_spell_index)
	var selected_block = spell_containter.get_child(spell_index)
	if unselected_block != null:
		unselected_block.select_block(false)
	if selected_block != null:
		selected_block.select_block(true)


func get_spell_code() -> Array:
	var spell_code = [spell_purple.my_symbol, spell_orange.my_symbol, spell_green.my_symbol]
	var spell_is_valid = is_spell_valid(spell_code)
	spell_purple.cast_spell(spell_is_valid)
	spell_orange.cast_spell(spell_is_valid)
	spell_green.cast_spell(spell_is_valid)
	return spell_code


func is_spell_valid(spell_code:Array) -> bool:
	return !spell_code.has(-1) && !spell_code.has(Rune.COLOR.NONE)


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
	if spell_index >= 0:
		var my_block = spell_containter.get_child(spell_index)
		my_block.my_symbol = color_index
		move_spell_block(1)
	emit_signal("bar_complete", color_index)
