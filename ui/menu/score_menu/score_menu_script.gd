extends Node2D

@onready var animation = $AnimationPlayer
@onready var rank_info_label = $Content/MarginContainer/MenuContainer/RankInfo
@onready var detail_info_label = $MarginContainer/VBoxContainer/DetailInfo

@onready var content_record_box = %Content
@onready var menu_record_container = %MenuContainer
@onready var enter_name_edit = %LineEdit
@onready var board = %GridContainer
@onready var save_option = %Save
@onready var skip_option = %Skip


@export var save_view_page_size: int = 13

var score_data: ScoreData
var current_mode : GameData.GAMEMODE = GameData.GAMEMODE.A
var rank_info_text: String = "You got %s place on the Score Rank\nPlease input your name to save your score\n"
var detail_info_text: String = "Time Played: %s\nUsed spells %d times\nMost used spell was %s"

var tween: Tween
var current_player_name_label:Label = null

enum MenuMode{ RECORD, VIEW }

signal dismiss


func _ready() -> void:
	#DEBUG
	#start_record(GameData.GAMEMODE.A,-1,1000,{}, 5.3)
	pass


func start_record(game_mode:GameData.GAMEMODE, rank:int, score:float, spells_count:Dictionary, game_time:float) -> void:
	var generated_score: ScoreData = gerenate_score_data(score, spells_count, game_time)
	current_mode = game_mode
	score_data = generated_score
	animation.play("enter_end_mode")
	self.visible = true
	content_record_box.visible = true
	enter_name_edit.visible = true
	save_option.visible = true
	
	if rank <= 0 || rank > GameData.MAX_BOARD_SIZE:
		setup_record_low_rank()
	else:
		setup_record_normal(rank)


func setup_record_normal(rank:int) -> void:
	rank_info_text = rank_info_text % get_ordinal(rank)
	setup_record_labels(score_data)
	populate_rank_view(rank)


func setup_record_labels(score:ScoreData) -> void:
	rank_info_label.text = rank_info_text 
	var detail_time = "Time Played: %s\n" % score.game_time
	var detail_spell_count = "Used spells %d time\n" % score.spells_cast if score.spells_cast == 1 else "" if score.spells_cast <=0 else "Used spells %d times\n" % score.spells_cast
	var detail_most_used = "Most used spell was %s" % score.most_used_spell if !score.most_used_spell.is_empty() else "You did not used any spells\nTry using them next time"
	detail_info_label.text = detail_time + detail_spell_count + detail_most_used


func setup_record_low_rank() -> void:
	rank_info_text = "You rank is too low to be on the scoreboard\n"
	if GameData.can_save(current_mode, score_data):
		rank_info_text += "However, you can save and see it in the player board\n"
	else:
		enter_name_edit.visible = false
		save_option.visible = false
		menu_record_container.alignment = BoxContainer.ALIGNMENT_CENTER
		content_record_box.size.y = 200 
		skip_option.text = "\nOK"
	
	setup_record_labels(score_data)
	var mode_string = GameData.GAMEMODE.find_key(current_mode)
	var current_view = GameData.view_board[mode_string]
	var max_page_size = min(save_view_page_size, current_view.size())
	var scores = current_view.slice(current_view.size()-max_page_size, current_view.size())
	populate_board(scores)


func populate_rank_view(rank: int) -> void:
	#FIXME Somehow the Score is looping back and get the 1st scores to populate back the stack
	var scores = []
	var mode_string = GameData.GAMEMODE.find_key(current_mode)
	var current_view = GameData.view_board[mode_string]
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
	
	populate_board(scores, rank, l+2)


func populate_board(score_list, current_rank:int = -1, start_rank:int = 1) -> void:
	var r = start_rank
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
	#FIXME CHECK THIS
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
	content_record_box.visible = false
	self.visible = true
	populate_board(GameData.view_board["A"])


func get_ordinal(num:int) -> String:
	if num >= 11 && num <= 13:
		return str(num)+"th"
	
	var last_digit = int(str(num)[-1])
	match last_digit:
		1:
			return str(num)+"st"
		2:
			return str(num)+"nd"
		3:
			return str(num)+"rd"
		_:
			return str(num)+"th"


func start_save_score_menu() -> void:
	if enter_name_edit.visible:
		enter_name_edit.grab_focus()
	else:
		skip_option.grab_focus()


func start_view_score_menu() -> void:
	pass


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


func end_menu() -> void:
	var menu_tween = create_tween()
	menu_tween.tween_property(self, "modulate:a", 0, 1)
	menu_tween.tween_callback(dismiss_menu)


func dismiss_menu() -> void:
	self.visible = false
	self.modulate.a = 1
	enter_name_edit.clear()
	var score_labels = board.get_children().slice(2)
	for label in score_labels:
		label.queue_free()
	dismiss.emit()


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
	#FIXME CHECK THIS
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


func _on_save_selected() -> void:
	score_data.player_name = enter_name_edit.text
	GameData.add_player_score(current_mode, score_data)
	end_menu()


func _on_skip_selected() -> void:
	end_menu()
