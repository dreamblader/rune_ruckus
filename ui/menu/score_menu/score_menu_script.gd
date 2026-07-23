extends Node2D

@onready var animation = $AnimationPlayer
@onready var rank_info_label = $Content/MarginContainer/MenuContainer/RankInfo
@onready var detail_info_label = $MarginContainer/VBoxContainer/DetailInfo

@onready var enter_name_edit = %LineEdit
@onready var save_option = %Save
@onready var skip_option = %Skip

@export var save_view_page_size: int = 15

var view_ranks: Array[ScoreData] = []
var controller_mode: bool = false
var rank_info_text: String = "You got %s place on the Score Rank\nPlease input your name to save your score"
var detail_info_text: String = "Time Played: %s\nUsed spells %d times\nMost used spell was %s"
var menu_index: int = 0
var menu_size: int = 2
var menu_mode: MenuMode = MenuMode.RECORD

var tween: Tween
var current_player_name_label:Label = null

enum MenuMode{ RECORD, VIEW }


func _ready() -> void:
	#DEBUG
	start_record(GameData.GAMEMODE.A,6,1000,{}, 5.3)

func start_record(game_mode:GameData.GAMEMODE, rank:int, score:float, spells_count:Dictionary, game_time:float) -> void:
	var score_data: ScoreData = gerenate_score_data(score, spells_count, game_time)
	animation.play("enter_end_mode")
	self.visible = true
	setup_record_labels(rank, score_data)
	populate_rank_view(score_data, rank, GameData.GAMEMODE.find_key(game_mode))


func setup_record_labels(rank:int, score:ScoreData) -> void:
	var rank_str = get_ordinal(rank)
	rank_info_label.text = rank_info_text % rank_str
	var detail_time = "Time Played: %s\n" % score.game_time
	var detail_spell_count = "Used spells %d time\n" % score.spells_cast if score.spells_cast == 1 else "Used spells %d times\n" % score.spells_cast
	var detail_most_used = "Most used spell was %s" % score.most_used_spell if score.most_used_spell != null else "You did not used any spells\nTry using them next time"
	detail_info_label.text = detail_time + detail_spell_count + detail_most_used


func populate_rank_view(score_data: ScoreData, rank: int, game_mode:String) -> void:
	var scores = []
	var current_view = GameData.view_board[game_mode]
	var max_page_size = min(save_view_page_size, current_view.size()+1)
	
	scores.append(score_data)
	
	var l = rank-2
	var r = rank-1
	while scores.size() < max_page_size:
		if l >= 0:
			scores.push_front(current_view[l])
			l-=1
		
		if r < current_view.size():
			scores.push_back(current_view[r])
			r+=1
	
	populate_board(scores, rank)


func populate_board(score_list, current_rank:int = -1) -> void:
	var board = %GridContainer
	var r = 1
	for score in score_list:
		var name_text = "%s -  %s" % [get_ordinal(r), score.player_name]
		var name_label = generate_score_label(name_text)
		var score_label = generate_score_label(str(score.score))
		if r == current_rank:
			current_player_name_label = name_label
			add_blink_tween_to_label(name_label)
			add_blink_tween_to_label(score_label)
		board.add_child(name_label)
		board.add_child(score_label)
		r+=1


func add_blink_tween_to_label(label:Label) -> void:
	var duration = 1
	var label_tween = create_tween()
	label.add_theme_constant_override("outline_size", 20)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label_tween.tween_property(label, "theme_override_colors/font_outline_color", Color.RED, duration)
	label_tween.tween_property(label, "theme_override_colors/font_outline_color", Color.BLACK, duration)
	label_tween.set_loops()


func generate_score_label(text:String) -> Label:
	var label = Label.new()
	var label_font = load("res://font/Stick-Regular.ttf")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.WHITE)
	label.add_theme_constant_override("outline_size", 5)
	label.add_theme_font_override("font", label_font)
	label.add_theme_font_size_override("font_size", 35)
	label.text = text
	return label


func start_view() -> void:
	animation.play("enter_menu_mode")
	self.visible = true


func get_ordinal(num:int) -> String:
	if num >= 11 && num <= 13:
		return str(num)+"th"
	
	var first_digit = int(str(num)[0])
	match first_digit:
		1:
			return str(num)+"st"
		2:
			return str(num)+"nd"
		3:
			return str(num)+"rd"
		_:
			return str(num)+"th"


func start_save_score_menu() -> void:
	menu_mode = MenuMode.RECORD
	enter_name_edit.grab_focus()


func start_view_score_menu() -> void:
	menu_mode = MenuMode.VIEW


func round_time(seconds:float) -> String:
	var display_string = ""
	var whole_minutes := int(seconds / 60)
	@warning_ignore("integer_division")
	var hours := int(whole_minutes /60)
	var minutes := whole_minutes%60
	var remaining_seconds := fmod(seconds, 60.0)
	if hours > 0:
		display_string += "%d:" % [hours]
	display_string += "%02d:" % [minutes]
	display_string += "%02d" % [remaining_seconds] if fmod(remaining_seconds,1.0) == 0 else "%06.3f" % [remaining_seconds]
	return display_string


func get_spell_count(spell_dict:Dictionary) -> int:
	var count = 0
	for spell_num in spell_dict.values():
		count += spell_num
	return count


func get_most_used_spell(spell_dict:Dictionary) -> String:
	var most_used_spell = ""
	for spell in spell_dict:
		if most_used_spell == "" || spell_dict[spell] > spell_dict[most_used_spell]:
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


func _on_line_edit_focus_entered() -> void:
	var styleBox: StyleBoxFlat = enter_name_edit.get_theme_stylebox("focus")
	tween = create_tween()
	tween.tween_property(styleBox, "border_color", Color(1,0,0), 1)
	tween.tween_property(styleBox, "border_color", Color(1,1,1), 1)
	tween.set_loops()


func _on_line_edit_focus_exited() -> void:
	tween.stop()
	tween = null


func _on_line_edit_text_changed(new_text: String) -> void:
	if current_player_name_label == null:
		return
	
	var name_sections = current_player_name_label.text.split("-", false, 2)
	
	if new_text.is_empty():
		current_player_name_label.text = name_sections[0]+"-  ???"
	else:
		current_player_name_label.text = name_sections[0]+"-  "+new_text
