extends Node

var GRID_SIZE: Vector2
var LOWEST_VERTICAL_RUNE_POSTION = 880
var ARENA_SIZE: Vector2

var rng = RandomNumberGenerator.new()

signal spell_complete()
signal runes_moved()
signal set_score(new_value)
signal submit_score_multiplier(multiplier)
signal submit_new_spell(spell_code)
signal add_difficulty(value)
signal call_easteregg(id)

func cast_spell(spell_code: Array, spell_effect:int, runes: Array) -> void:
	#TODO
	var rgb_runes = [Rune.COLOR.RED, Rune.COLOR.GREEN, Rune.COLOR.BLUE]
	var ypo_runes = [Rune.COLOR.YELLOW, Rune.COLOR.PURPLE, Rune.COLOR.ORANGE]
	
	match spell_effect:
		Spells.Effect.XXX:
			remove_all_runes(runes, spell_code[0])
		Spells.Effect.XYX:
			await switch_runes(runes, spell_code[0], spell_code[1]).completed
		Spells.Effect.BYG:
			special_set_runes_explode(runes, 2)
		Spells.Effect.RGB:
			await switch_types(runes, ypo_runes, rgb_runes).completed
		Spells.Effect.YPO:
			await switch_types(runes, rgb_runes, ypo_runes).completed
		Spells.Effect.POG:
			emit_signal("set_score", 2)
			remove_random_runes(runes, 1, 100, 10)
		Spells.Effect.PYG:
			await create_special_runes(runes, Rune.SPECIALS.PYG).completed
		Spells.Effect.ROY:
			await create_special_runes(runes, Rune.SPECIALS.ROY).completed
		Spells.Effect.GOB:
			await create_special_runes(runes, Rune.SPECIALS.GOB).completed
		Spells.Effect.BOY:
			await create_special_runes(runes, Rune.SPECIALS.BOY).completed
		Spells.Effect.POO:
			emit_signal("set_score", 0)
			emit_signal("submit_score_multiplier", 0.75)
			remove_all_runes(runes, -1)
		Spells.Effect.BOG:
			sink_runes(runes)
			await self.runes_moved
		Spells.Effect.RPG:
			#TEST
			roll_d20(runes)
		Spells.Effect.PRO:
			emit_signal("add_difficulty", 1)
		Spells.Effect.BRO:
			emit_signal("add_difficulty", -1)
		Spells.Effect.ORG:
			reorganize_runes(runes)
			await self.runes_moved
		Spells.Effect.ORB:
			#TEST
			pass
		Spells.Effect.YOO:
			#TEST
			emit_signal("call_easteregg", 0)
			#call_easter_egg(0)
		Spells.Effect.OBG:
			#TEST
			emit_signal("call_easteregg", 1)
		Spells.Effect.CHAOS:
			#TEST
			chaos_spell()
	
	emit_signal("spell_complete")


func remove_all_runes(runes: Array, rune_code: int) -> void:
	for rune in runes:
		if rune.color == rune_code || rune_code < 0:
			rune.max_power = 0


func switch_runes(runes: Array, rune_to_transform: int, rune_to_be_transform: int) -> void:
	for rune in runes:
		if rune.color == rune_to_be_transform:
			rune.switch_color(rune_to_transform)
	
	await wait_runes_to_update(runes).completed


func wait_runes_to_update(runes: Array) -> void:
	for rune in runes:
		if rune != null && is_instance_valid(rune) && rune.update_tween != null:
			await rune.updated
	await get_tree().idle_frame


func special_set_runes_explode (runes: Array, new_max:int) -> void:
	for rune in runes:
		rune.max_power = new_max


func switch_types(runes: Array, from:Array, randomly_to:Array) -> void:
	for rune in runes:
		if from.has(rune.color) || from.is_empty():
			var random_index = rng.randi_range(0, randomly_to.size()-1)
			var new_color = randomly_to[random_index]
			rune.switch_color(new_color)
	
	await wait_runes_to_update(runes).completed


func remove_random_runes(runes: Array, min_num: int, max_num:int, odds:int) -> void:
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


func create_special_runes(runes: Array, type:int) -> void:
	var min_special_runes = 4
	var max_special_runes = 20
	var special_runes_odds = 5
	var special_runes = rune_picker(runes, min_special_runes, max_special_runes, special_runes_odds)
	for special_rune in special_runes:
		special_rune.switch_color(Rune.COLOR.SPECIAL, type)
	
	await wait_runes_to_update(runes).completed


func sink_runes(runes: Array) -> void:
	var sink_time = 1.5
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	for rune in runes:
		tween.parallel().tween_property(rune, "position:y", rune.position.y+GRID_SIZE.y, sink_time)
	tween.tween_callback(Callable(self, "sink_finish").bind(runes))


func sink_finish(runes:Array) -> void:
	emit_signal("set_score", 0)
	var sunk_destruction_position = LOWEST_VERTICAL_RUNE_POSTION + 1
	for rune in runes:
		if rune.position.y > sunk_destruction_position:
			rune.queue_free()
	emit_signal("runes_moved")


func roll_d20(runes: Array) -> void:
	var roll: int = rng.randi_range(1, 20)
	var all_non_special_runes = [Rune.COLOR.RED, Rune.COLOR.YELLOW, Rune.COLOR.BLUE, Rune.COLOR.PURPLE, Rune.COLOR.GREEN, Rune.COLOR.ORANGE, Rune.COLOR.NONE]
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
		emit_signal("set_score", 2)
		for rune in runes:
			rune.max_power = 0
		emit_signal("submit_new_spell", [Rune.COLOR.RED, Rune.COLOR.PURPLE, Rune.COLOR.GREEN])


func submit_random_spell(possible_combinations:Array) -> void:
	var new_spell: Array = []
	for i in range(3):
			var random_index = rng.randi(0, possible_combinations.size()-1)
			new_spell.push_back(possible_combinations[random_index])
	emit_signal("submit_new_spell", new_spell)


func reorganize_runes(runes: Array) -> void:
	var organize_time = 1.5
	var tween = create_tween()
	var max_col_size = (ARENA_SIZE.x/GRID_SIZE.x)
	var max_row_size = (ARENA_SIZE.y/GRID_SIZE.y)
	var x_index = 0
	var y_index = 0
	tween.set_ease(Tween.EASE_IN)
	runes.sort_custom(Callable(Rune, "colorComparison"))
	for rune in runes:
		var new_position = Vector2(x_index*GRID_SIZE.x, LOWEST_VERTICAL_RUNE_POSTION-(y_index*GRID_SIZE.y))
		rune.column_pos = new_position.x
		tween.parallel().tween_property(rune, "position", new_position, organize_time)
		x_index += 1
		if x_index >= max_col_size:
			x_index = 0
			y_index += 1
	
	tween.tween_callback(Callable(self, "emit_signal").bind("runes_moved"))


func call_easter_egg(id:int) -> void:
	#TODO
	pass


func chaos_spell() -> void:
	#TODO
	pass
