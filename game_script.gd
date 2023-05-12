extends Control

export (PackedScene) var orb_scene

onready var data = $Content/RightContainer/DataContent
onready var board_viewport = $Content/MidContainer/Control/ViewPortBorder/ViewportContainer
onready var board = $Content/MidContainer/Control/ViewPortBorder/ViewportContainer/Viewport/Board
onready var left_panel = $Content/LeftPadding
onready var death_menu = $DeathMenu

var orb_travel_time:float = 0.65
var multiplier: int = 1
var explode_point: int = 50
var gravity_point: int = 1 #per 40 pixels traveled
var color_mix_pool:int = -1

var current_rune_score = 0
var current_rune_chain = 1



var score:int = 0
var high_score:int = 10000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	update_score()
	update_high_score()


func update_score() -> void:
	data.set_score(str("%08d" % score))
	if score > high_score:
		high_score = score
		update_high_score()


func update_high_score() -> void:
	data.set_highscore(str("%08d" % high_score))


func set_score_temp() -> void:
	data.set_score(str(current_rune_chain)+" x "+str(current_rune_score))


func _on_Board_emit_orb(at_position, to_color) -> void:
	var tween = create_tween()
	var offset = Vector2(40, 100) + Vector2(left_panel.rect_size.x, 0)
	var go_to = data.get_bar_position(to_color) + Vector2(60, 60)
	var orb = orb_scene.instance()
	orb.position = at_position + offset
	orb.color = to_color
	add_child(orb)
	tween.tween_property(orb, "position", go_to, orb_travel_time)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_callback(self, "orb_reached_goal", [orb, to_color])


func orb_reached_goal(orb, color_index:int) -> void:
	data.color_up(1, color_index)
	orb.queue_free()


func _on_Board_emit_score(value) -> void:
	current_rune_score += value * explode_point
	set_score_temp()


func _on_Board_emit_chain(value) -> void:
	current_rune_chain = max(1, value)
	set_score_temp()


func _on_Board_emit_preview_runes(preview_runes:Array) -> void:
	if data == null:
		yield($Content/RightContainer/DataContent, "ready")
		data = $Content/RightContainer/DataContent
	data.set_preview(preview_runes)


func _on_Board_submit_score() -> void:
	score += current_rune_chain*current_rune_score
	current_rune_score = 0
	current_rune_chain = 0
	update_score()


func _on_DataContent_bar_complete(color_index) -> void:
	if !board.locked_colors.empty():
		if color_mix_pool < 0 && color_index < Rune.COLOR.GREEN:
			color_mix_pool = color_index
		elif color_mix_pool != color_index:
			var mix_success:bool = mix_color(color_index)
			if mix_success:
				color_mix_pool = -1
			elif is_final_mix_and_next_color_is_from_it(color_index) || board.locked_colors.size() > 1:
				color_mix_pool = color_index


func mix_color(color_to_mix:int) -> bool:
	match color_to_mix:
		Rune.COLOR.RED:
			if is_a_orange_mix(color_mix_pool):
				return unlock_color(Rune.COLOR.ORANGE)
			elif is_a_purple_mix(color_mix_pool):
				return unlock_color(Rune.COLOR.PURPLE)
		Rune.COLOR.YELLOW:
			if is_a_orange_mix(color_mix_pool):
				return unlock_color(Rune.COLOR.ORANGE)
			elif is_a_green_mix(color_mix_pool):
				return unlock_color(Rune.COLOR.GREEN)
		Rune.COLOR.BLUE:
			if is_a_green_mix(color_mix_pool):
				return unlock_color(Rune.COLOR.GREEN)
			elif is_a_purple_mix(color_mix_pool):
				return unlock_color(Rune.COLOR.PURPLE)
	return false


func unlock_color(color_index: int) -> bool:
	data.unlock_color_bar(color_index)
	return board.unlock_color(color_index)


func is_final_mix_and_next_color_is_from_it(next_color:int) -> bool:
	return board.locked_colors.size() == 1 && is_color_from_the_mix(next_color, board.locked_colors[0])


func is_color_from_the_mix(color_check:int, mix_check:int) -> bool:
	match mix_check:
		Rune.COLOR.GREEN:
			return is_a_green_mix(color_check)
		Rune.COLOR.PURPLE:
			return is_a_purple_mix(color_check)
		Rune.COLOR.ORANGE:
			return is_a_orange_mix(color_check)
		_:
			return false


func is_a_purple_mix(color_check:int) -> bool:
	return color_check == Rune.COLOR.RED || color_check == Rune.COLOR.BLUE


func is_a_green_mix(color_check:int) -> bool:
	return color_check == Rune.COLOR.YELLOW || color_check == Rune.COLOR.BLUE


func is_a_orange_mix(color_check:int) -> bool:
	return color_check == Rune.COLOR.RED || color_check == Rune.COLOR.YELLOW


func _on_Board_game_over(menu_flag) -> void:
	if menu_flag:
		death_menu.visible = true
	else:
		board_viewport.material.set_shader_param("enabled", true)
