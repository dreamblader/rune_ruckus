extends Node2D

@onready var animation = $AnimationPlayer
@onready var rank_info_label = $Content/MarginContainer/MenuContainer/RankInfo
@onready var detail_info_label = $MarginContainer/VBoxContainer/DetailInfo

@onready var enter_name_edit = $Content/MarginContainer/MenuContainer/LineEdit

var view_ranks: Array[ScoreData] = []
var controller_mode: bool = false
var rank_info_text: String = "You got %s place on the Score Rank\nPlease input your name to save your score"
var detail_info_text: String = "Time Played: %s\nUsed spells %d times\nMost used spell was %s"
var menu_index: int = 0
var menu_size: int = 2
var menu_mode: MenuMode = MenuMode.RECORD
var can_use_menu:bool = false

var tween: Tween

enum MenuMode{ RECORD, VIEW }

func _input(event: InputEvent) -> void:
	if can_use_menu:
		match menu_mode:
			MenuMode.RECORD:
				check_record_menu_input(event)
			MenuMode.VIEW:
				pass

func check_record_menu_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		move_menu(1)
	if event.is_action("ui_up"):
		move_menu(-1)


func move_menu(value:int) -> void:
	menu_index = (menu_index+value)%menu_size
	if menu_index < 0: 
		menu_index = menu_size-1
	update_menu()


func start_record(rank:int, score:float, spells_count:Dictionary, game_time:float) -> void:
	var score_data: ScoreData = gerenate_score_data(score, spells_count, game_time)
	animation.play("enter_end_mode")
	self.visible = true
	setup_record_labels(rank, score_data)
	start_save_score_menu()


func setup_record_labels(rank:int, score:ScoreData) -> void:
	var rank_str = str(rank)+get_ordinal(rank)
	rank_info_label.text = rank_info_text % rank_str
	var detail_time = "Time Played: %s\n" % score.game_time
	var detail_spell_count = "Used spells %d time\n" % score.spells_cast if score.spells_cast == 1 else "Used spells %d times\n" % score.spells_cast
	var detail_most_used = "Most used spell was %s" % score.most_used_spell if score.most_used_spell != null else "You did not used any spells\nTry using them next time"
	detail_info_label.text = detail_time + detail_spell_count + detail_most_used
	#if(rank < )


func start_view() -> void:
	animation.play("enter_menu_mode")
	self.visible = true


func get_ordinal(num:int) -> String:
	if num >= 11 && num <= 13:
		return "th"
	
	var first_digit = int(str(num)[0])
	match first_digit:
		1:
			return "st"
		2:
			return "nd"
		3:
			return "rd"
		_:
			return "th"


func start_save_score_menu() -> void:
	menu_mode = MenuMode.RECORD
	menu_size = 3
	can_use_menu = true
	update_menu()


func update_menu() -> void:
	match menu_index:
		0:
			animation.stop()
			flash_edit_box()
		1:
			flash_edit_box(true)
			animation.play("save_select")
		2:
			flash_edit_box(true)
			animation.play("skip_select")


func flash_edit_box(stop:bool = false) -> void:
	if stop:
		enter_name_edit.release_focus()
		if tween != null:
			tween.stop()
			tween.kill()
	else:
		enter_name_edit.grab_focus()
		tween = create_tween()
		#tween.tween_property(enter_name_edit, "")


func start_view_score_menu() -> void:
	menu_mode = MenuMode.VIEW
	can_use_menu = true


func round_time(seconds:float) -> String:
	var minutes := int(seconds / 60)
	@warning_ignore("integer_division")
	var hours := int(minutes /60)
	var remaining_seconds := fmod(seconds, 60.0)
	if hours > 0:
		return "%d:%02d:%05.2f" % [hours, minutes, remaining_seconds]
	else:
		return "%02d:%05.2f" % [minutes, remaining_seconds]


func get_spell_count(spell_dict:Dictionary) -> int:
	var count = 0
	for spell_num in spell_dict.values():
		count += spell_num
	return count


func get_most_used_spell(spell_dict:Dictionary) -> String:
	var most_used_spell = null
	for spell in spell_dict:
		if most_used_spell == null || spell_dict[spell] > spell_dict[most_used_spell]:
			most_used_spell = spell
	return most_used_spell


func gerenate_score_data(score:float, spells_count:Dictionary, game_time:float) -> ScoreData:
	var time = round_time(game_time)
	var spell_count = get_spell_count(spells_count)
	var most_used_spell = get_most_used_spell(spells_count)
	return ScoreData.new("???", score, time, spell_count, most_used_spell)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"enter_end_mode":
			start_save_score_menu()
		"enter_menu_mode":
			start_view_score_menu()
