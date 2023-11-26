extends Node2D
class_name Game

#GLOBALS
var GRAVITY:float = 15
var GRID_SIZE:Vector2 = Vector2(80.0, 80.0)
var GAME_SIZE:Vector2 = Vector2(6.0, 12.0)
var TICK_MOVE: float = GRID_SIZE.y/2
var FADE_TIME: float = 0.35
var COLOR_MULT: int = 6 #increase +1 per extra color (starts at 2 colors)
var CHAIN_MULT: int = 4
var LEVEL: int = 1
var SCORE: int = 1
var LOWEST_VERTICAL_RUNE_POSTION = 880

var is_playing:bool = false
var pause: bool = false
var is_over:bool = false
var on_wait: bool = false
var continue_chain = false

var unlocked_colors: Array = [Rune.COLOR.RED, Rune.COLOR.YELLOW, Rune.COLOR.BLUE]
var locked_colors: Array = [Rune.COLOR.GREEN, Rune.COLOR.PURPLE, Rune.COLOR.ORANGE]
var next_runes: Array = []
var color_chain: Array = []
var rng = RandomNumberGenerator.new()
var spell_code_to_submit: Array = []

var death_tween:SceneTreeTween
var death_final_position = Vector2(280, 400)
var death_final_scale = Vector2(4, 4)

export (PackedScene) var rune_scene

onready var player = $Player
onready var death_tile = $DeathTile
onready var death = $Death
onready var death_label = $UDiedLabel/MovingLabel
onready var pause_label = $PauseLabel/MovingLabel
onready var death_bell_audio = $DeathBell
onready var death_laugh_audio = $DeathLaugh
onready var spellchecker = $SpellChecker
onready var background = $Background

signal emit_orb(at_position)
signal emit_preview_runes(preview_runes)
signal emit_score(value)
signal emit_chain(value)
signal submit_score()
signal submit_score_multiplier(value)
signal game_over(menu_flag)
signal cast_spell()
signal runes_moved()
signal submit_spell_code(code)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spell"):
		apply_spell([Rune.COLOR.ORANGE, Rune.COLOR.RED, Rune.COLOR.GREEN]) # TODO TESTER
		#emit_signal("cast_spell")
	
	if is_over && event.is_action_pressed("ui_accept"):
		skip_death_animation()
	elif death_tween == null && is_playing && event.is_action_pressed("ui_accept"):
		pause()


func start():
	rng.randomize()
	generate_runes()
	player.tick_move = TICK_MOVE
	player.move = GRID_SIZE.x
	spawn_player()
	is_over = false
	is_playing = true


func end():
	death_tile.visible = true
	death.position = Vector2(280,40)
	death.scale = Vector2(1,1)
	death.visible = false
	death_label.disappear()
	next_runes.empty()
	emit_signal("emit_preview_runes", next_runes)
	reset_color_progress()
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		rune.queue_free()


func reset_color_progress() -> void:
	unlocked_colors = [Rune.COLOR.RED, Rune.COLOR.YELLOW, Rune.COLOR.BLUE]
	locked_colors = [Rune.COLOR.GREEN, Rune.COLOR.PURPLE, Rune.COLOR.ORANGE]


func pause():
	pause = !pause
	get_tree().paused = pause
	toggle_runes_mask(pause)
	if pause:
		pause_label.appear()
	else:
		pause_label.disappear()


func toggle_runes_mask(flag:bool) -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		if flag:
			rune.mask_rune(rng.randi_range(0, 8))
		else:
			rune.unmask_rune()


func generate_runes() -> void:
	while next_runes.size() < 4:
		var random_color_index = rng.randi_range(0, unlocked_colors.size()-1)
		next_runes.append(unlocked_colors[random_color_index])
	emit_signal("emit_preview_runes", next_runes)


func spawn_player() -> void:
	if death_tile.did_u_died():
		start_game_over()
	else:
		player.respawn(next_runes.pop_front(), next_runes.pop_front())
		generate_runes()


func start_game_over() -> void:
	emit_signal("game_over", false)
	next_runes.clear()
	awake_death_icon()
	LEVEL = 1
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		rune.end()


func awake_death_icon() -> void:
	death_tween = get_tree().create_tween()
	var death_animation_time = 3.0
	var death_animation_delay = 2.0
	death_tile.visible = false
	death.visible = true
	death_bell_audio.play()
	death_tween.set_trans(Tween.TRANS_SINE)
	death_tween.set_ease(Tween.EASE_OUT)
	death_tween.tween_callback(self, "set_is_over", [true]).set_delay(death_animation_delay)
	death_tween.parallel().tween_callback(death_bell_audio, "play").set_delay(death_animation_delay)
	death_tween.parallel().tween_property(death, "position", death_final_position, death_animation_time).set_delay(death_animation_delay)
	death_tween.parallel().tween_property(death, "scale", death_final_scale, death_animation_time).set_delay(death_animation_delay) 
	death_tween.tween_callback(self, "show_u_died_label")
	death_tween.tween_callback(self, "emit_signal", ["game_over", true]).set_delay(0.5)


func set_is_over(flag:bool) -> void:
	is_over = flag


func show_u_died_label() -> void:
	death_tween = null
	death_laugh_audio.play()
	death_label.appear()


func skip_death_animation() -> void:
	if death_tween != null:
		death_tween.kill()
		death_tween = null
		death_laugh_audio.play()
		death_tile.visible = false
		death.visible = true
		death.position = death_final_position
		death.scale = death_final_scale
		death_label.force_appear()
		emit_signal("game_over", true)


func solve(chain_count_start:int) -> void:
	var extra_padding_time: float = 0.1
	var runes = get_tree().get_nodes_in_group("Rune")
	if !runes.empty():
		yield(wait_runes_touch_the_ground(runes), "completed")
		add_pitch(runes, chain_count_start)
		check_runes(runes)
		wait_runes_explode(runes)
		if continue_chain:
			emit_signal("emit_chain", chain_count_start+get_color_chain_score())
			yield(get_tree().create_timer(FADE_TIME+extra_padding_time, false), "timeout")
			solve(chain_count_start+CHAIN_MULT)
			return
	spawn_player()
	color_chain.clear()
	emit_signal("submit_score")
	SCORE = 1


func wait_runes_touch_the_ground(runes) -> void:
	for rune in runes:
		if rune != null && is_instance_valid(rune) && rune.is_floating:
			yield(rune, "touch_the_ground")
	yield(get_tree(), "idle_frame")


func add_pitch(runes, chain_number) -> void:
	var chain_pitch = 0
	if chain_number > 1:
		chain_pitch = floor(chain_number-1/CHAIN_MULT)/10
	for rune in runes:
		if rune != null && is_instance_valid(rune):
			rune.set_pitch(chain_pitch)


func check_runes(runes) -> void:
	for rune in runes:
		if rune != null && is_instance_valid(rune):
			rune.init_chain_check()


func wait_runes_explode(runes) -> void:
	continue_chain = false
	for rune in runes:
		if rune != null && is_instance_valid(rune):
			rune.explode()
			if rune.tween != null:
				if !color_chain.has(rune.color):
					color_chain.append(rune.color)
				emit_signal("emit_score", SCORE)
				continue_chain = true


func _on_Player_place_runes(insta_position, pivot_rune, side_rune) -> void:
	put_new_rune(insta_position + pivot_rune.position, pivot_rune)
	put_new_rune(insta_position + side_rune.position, side_rune)
	solve(0)


func put_new_rune(rune_position, old_rune) -> void:
	var new_rune = rune_scene.instance()
	new_rune.add_to_group("Rune")
	new_rune.position = rune_position
	new_rune.gravity = GRAVITY
	new_rune.fade_time = FADE_TIME
	add_child(new_rune)
	new_rune.color = old_rune.color
	new_rune.connect("explode", self, "_on_Rune_explode")


func get_color_chain_score() -> int:
	if color_chain.size() > 1:
		var chain_power = 0
		for i in range(color_chain.size()-1):
			chain_power +=  COLOR_MULT+i
		return chain_power
	else:
		return 0


func unlock_color(color_index:int) -> bool:
	var locked_index = locked_colors.find(color_index)
	if locked_index >= 0:
		locked_colors.remove(color_index)
		unlocked_colors.append(color_index)
		return true
	else:
		return false


func apply_spell(spell_code:Array) -> void:
	#TODO
	var spell_effect = spellchecker.check(spell_code)
	var rgb_runes = [Rune.COLOR.RED, Rune.COLOR.GREEN, Rune.COLOR.BLUE]
	var ypo_runes = [Rune.COLOR.YELLOW, Rune.COLOR.PURPLE, Rune.COLOR.ORANGE]
	
	if spell_effect != Spells.Effect.NONE:
		player.disable_player()
	
	match spell_effect:
		Spells.Effect.XXX:
			remove_all_runes(spell_code[0])
		Spells.Effect.XYX:
			yield(switch_runes(spell_code[0], spell_code[1]), "completed")
		Spells.Effect.BYG:
			special_set_runes_explode(2)
		Spells.Effect.RGB:
			yield(switch_types(get_tree().get_nodes_in_group("Rune"), ypo_runes, rgb_runes), "completed")
		Spells.Effect.YPO:
			yield(switch_types(get_tree().get_nodes_in_group("Rune"), rgb_runes, ypo_runes), "completed")
		Spells.Effect.POG:
			SCORE = 2
			remove_random_runes(1, 100, 10)
		Spells.Effect.PYG:
			yield(create_special_runes(Rune.SPECIALS.PYG), "completed")
		Spells.Effect.ROY:
			yield(create_special_runes(Rune.SPECIALS.ROY), "completed")
		Spells.Effect.GOB:
			yield(create_special_runes(Rune.SPECIALS.GOB), "completed")
		Spells.Effect.BOY:
			yield(create_special_runes(Rune.SPECIALS.BOY), "completed")
		Spells.Effect.POO:
			SCORE = 0
			emit_signal("submit_score_multiplier", 0.75)
			remove_all_runes(-1)
		Spells.Effect.BOG:
			sink_runes()
			yield(self, "runes_moved")
		Spells.Effect.RPG:
			#TEST
			roll_d20()
		Spells.Effect.PRO:
			#TEST
			add_difficulty(1)
		Spells.Effect.BRO:
			#TEST
			add_difficulty(-1)
		Spells.Effect.ORG:
			reorganize_runes()
			yield(self, "runes_moved")
		Spells.Effect.ORB:
			#TEST
			pass
		Spells.Effect.YOO:
			#TEST
			call_easter_egg(0)
		Spells.Effect.OBG:
			#TEST
			call_easter_egg(1)
		Spells.Effect.CHAOS:
			#TEST
			chaos_spell()
	
	solve(0)


func remove_all_runes(rune_code: int) -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		if rune.color == rune_code || rune_code < 0:
			rune.max_power = 0


func switch_runes(rune_to_transform: int, rune_to_be_transform: int) -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		if rune.color == rune_to_be_transform:
			rune.switch_color(rune_to_transform)
	
	yield(wait_runes_to_update(runes), "completed")


func wait_runes_to_update(runes: Array) -> void:
	for rune in runes:
		if rune != null && is_instance_valid(rune) && rune.update_tween != null:
			yield(rune, "updated")
	yield(get_tree(), "idle_frame")


func special_set_runes_explode (new_max:int) -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		rune.max_power = new_max


func switch_types(runes: Array, from:Array, randomly_to:Array) -> void:
	for rune in runes:
		if from.has(rune.color) || from.empty():
			var random_index = rng.randi_range(0, randomly_to.size()-1)
			var new_color = randomly_to[random_index]
			rune.switch_color(new_color)
	
	yield(wait_runes_to_update(runes), "completed")


func remove_random_runes(min_num: int, max_num:int, odds:int) -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	var remove_runes = rune_picker(runes, min_num, max_num, odds)
	for remove_this_rune in remove_runes:
		remove_this_rune.max_power = 0


func rune_picker(runes:Array, min_num:int, max_num:int, odds:int) -> Array:
	var result: Array = []
	
	if runes.size() <= min_num:
		return runes
		
	while result.size() < min_num:
		var pick_index = rng.randi_range(0, runes.size()-1)
		result.append(runes.pop_at(pick_index))
	
	for rune in runes:
		var roll = rng.randi_range(1, odds)
		if roll == odds:
			result.append(rune)
			if result.size() >= max_num:
				break;
		
	return result


func create_special_runes(type:int) -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	var min_special_runes = 4
	var max_special_runes = 20
	var special_runes_odds = 5
	var special_runes = rune_picker(runes, min_special_runes, max_special_runes, special_runes_odds)
	for special_rune in special_runes:
		special_rune.switch_color(Rune.COLOR.SPECIAL, type)
	
	yield(wait_runes_to_update(runes), "completed")


func sink_runes() -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	var sink_time = 1.5
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	for rune in runes:
		tween.parallel().tween_property(rune, "position:y", rune.position.y+GRID_SIZE.y, sink_time)
	tween.tween_callback(self, "sink_finish", [runes])


func sink_finish(runes:Array) -> void:
	SCORE = 0
	var sunk_destruction_position = LOWEST_VERTICAL_RUNE_POSTION + 1
	for rune in runes:
		if rune.position.y > sunk_destruction_position:
			rune.queue_free()
	emit_signal("runes_moved")


func roll_d20() -> void:
	var roll: int = rng.randi_range(1, 20)
	var all_non_special_runes = [Rune.COLOR.RED, Rune.COLOR.YELLOW, Rune.COLOR.BLUE, Rune.COLOR.PURPLE, Rune.COLOR.GREEN, Rune.COLOR.ORANGE, Rune.COLOR.NONE]
	var runes = get_tree().get_nodes_in_group("Rune")
	if roll >= 2 && roll <= 4:
		#Spell Reroll
		submit_random_spell(all_non_special_runes)
	elif roll >=5 && roll <=7:
		#Small Runes Change
		var picked_runes = rune_picker(runes, 1, 30, 10)
		switch_types(picked_runes, [], all_non_special_runes)
	elif roll >=8 && roll <=10:
		#Medium Runes Change
		var picked_runes = rune_picker(runes, 4, 50, 5)
		var picked_types:Array = []
		for i in range(4):
			var pick_type_index = rng.randi_range(0, all_non_special_runes.size()-1)
			picked_types.push_back(all_non_special_runes.pop_at(pick_type_index)) 
		switch_types(picked_runes, [], picked_types)
	elif roll >=11 && roll <=13:
		#Max Runes Change
		var picked_runes = rune_picker(runes, 10, 100, 4)
		var picked_types:Array = []
		for i in range(2):
			var pick_type_index = rng.randi_range(0, all_non_special_runes.size()-1)
			picked_types.push_back(all_non_special_runes.pop_at(pick_type_index)) 
		picked_types.push_back(Rune.COLOR.SPECIAL)
		switch_types(picked_runes, [], picked_types)
	elif roll >=14 && roll <=16:
		#Special Roll
		for rune in runes:
			var rune_roll: int = rng.randi_range(1, 20)
			if rune_roll > 6 && rune_roll <= 13:
				rune.switch_color(Rune.COLOR.SPECIAL)
			elif rune_roll > 13:
				rune.max_power = 0
	elif roll >=17 && roll <=19:
		#Special Roll and New Spell
		for rune in runes:
			var rune_roll: int = rng.randi_range(1, 20)
			if rune_roll > 2 && rune_roll <= 11:
				rune.switch_color(Rune.COLOR.SPECIAL)
			elif rune_roll > 11:
				rune.max_power = 0
		all_non_special_runes.pop_back()
		submit_random_spell(all_non_special_runes)
	elif roll == 20:
		#CRITICAL Explosion and Reroll
		SCORE = 2
		for rune in runes:
			rune.max_power = 0
		spell_code_to_submit = [Rune.COLOR.RED, Rune.COLOR.PURPLE, Rune.COLOR.GREEN]


func submit_random_spell(possible_combinations:Array) -> void:
	var new_spell: Array = []
	for i in range(3):
			var random_index = rng.randi(0, possible_combinations.size()-1)
			new_spell.push_back(possible_combinations[random_index])
	spell_code_to_submit = new_spell


func add_difficulty(value:int) -> void:
	#TODO
	pass


func reorganize_runes() -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	var organize_time = 1.5
	var tween = create_tween()
	var max_col_size = (background.rect_size.x/GRID_SIZE.x)*2
	var max_row_size = (background.rect_size.y/GRID_SIZE.y)*2
	var x_index = 0
	var y_index = 0
	tween.set_ease(Tween.EASE_IN)
	runes.sort_custom(Rune, "colorComparison")
	for rune in runes:
		var new_position = Vector2(x_index*GRID_SIZE.x, LOWEST_VERTICAL_RUNE_POSTION-(y_index*GRID_SIZE.y))
		rune.column_pos = new_position.x
		tween.parallel().tween_property(rune, "position", new_position, organize_time)
		x_index += 1
		if x_index >= max_col_size:
			x_index = 0
			y_index += 1
	
	tween.tween_callback(self, "emit_signal", ["runes_moved"])


func call_easter_egg(id:int) -> void:
	#TODO
	pass


func chaos_spell() -> void:
	#TODO
	pass


func _on_Rune_explode(explode_position, explode_color) -> void:
	emit_signal("emit_orb", explode_position, explode_color)


func _on_Player_send_score(score) -> void:
	emit_signal("submit_score", score)
