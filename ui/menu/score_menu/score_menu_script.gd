extends Node2D

@onready var animation = $AnimationPlayer
@onready var rank_info_label = $Content/MarginContainer/MenuContainer/RankInfo

var controller_mode: bool = false
var rank_info_text: String = "You got %s place on the Score Rank\nPlease input your name to save your score"
var menu_index: int = 0


func start_record(rank:int, score:float, spells_count:Dictionary, game_time:float) -> void:
	animation.play("enter_end_mode")
	self.visible = true
	var rank_str = str(rank)+get_ordinal(rank)
	rank_info_label.text = rank_info_text % rank_str
	pass


func start_view() -> void:
	animation.play("enter_menu_mode")
	self.visible = true


func get_ordinal(num:int) -> String:
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
	pass


func start_view_score_menu() -> void:
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"enter_end_mode":
			start_save_score_menu()
		"enter_menu_mode":
			start_view_score_menu()
