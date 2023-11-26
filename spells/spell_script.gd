extends Node
class_name Spells

enum Effect { NONE, XXX, XYX, BYG , RGB, YPO, POG, PYG, ROY, GOB, BOY, POO, BOG, RPG, PRO, BRO, ORG, ORB, YOO, OBG, CHAOS}


func check(spell_code: Array) -> int:
	if spell_is_valid(spell_code):
		
		if spell_code[0] == spell_code[2]:
			return check_same_runes(spell_code)
		
		var scheme = check_color_schemes(spell_code)
		
		if scheme > 0:
			return scheme
		else:
			return check_specific_spells(spell_code)
	else:
		return Effect.NONE


func check_same_runes(spell_code: Array) -> int:
	if spell_code[0] == spell_code[1]:
		return Effect.XXX
	else:
		return Effect.XYX


func check_color_schemes(spell_code: Array) -> int:
	if spell_code.has(Rune.COLOR.RED) && spell_code.has(Rune.COLOR.GREEN) && spell_code.has(Rune.COLOR.BLUE):
		return Effect.RGB
	elif spell_code.has(Rune.COLOR.YELLOW) && spell_code.has(Rune.COLOR.PURPLE) && spell_code.has(Rune.COLOR.ORANGE):
		return Effect.YPO
	else:
		return -1


func check_specific_spells(spell_code:Array) -> int:
	match spell_code[0]:
		Rune.COLOR.RED:
			return red_specifics(spell_code[1], spell_code[2])
		Rune.COLOR.BLUE:
			return blue_specifics(spell_code[1], spell_code[2])
		Rune.COLOR.YELLOW:
			return yellow_specifics(spell_code[1], spell_code[2])
		Rune.COLOR.PURPLE:
			return purple_specifics(spell_code[1], spell_code[2])
		Rune.COLOR.ORANGE:
			return orange_specifics(spell_code[1], spell_code[2])
		Rune.COLOR.GREEN:
			return green_specifics(spell_code[1], spell_code[2])
		_:
			return Effect.CHAOS


func red_specifics(mid_rune, final_rune) -> int:
	if mid_rune == Rune.COLOR.ORANGE && final_rune == Rune.COLOR.YELLOW:
		return Effect.ROY
	elif mid_rune == Rune.COLOR.PURPLE && final_rune == Rune.COLOR.GREEN:
		return Effect.RPG
	else:
		return Effect.CHAOS


func blue_specifics(mid_rune, final_rune) -> int:
	if mid_rune == Rune.COLOR.YELLOW && final_rune == Rune.COLOR.GREEN:
		return Effect.BYG
	elif mid_rune == Rune.COLOR.ORANGE && final_rune == Rune.COLOR.GREEN:
		return Effect.BOG
	elif mid_rune == Rune.COLOR.ORANGE && final_rune == Rune.COLOR.YELLOW:
		return Effect.BOY
	elif mid_rune == Rune.COLOR.RED && final_rune == Rune.COLOR.ORANGE:
		return Effect.BRO
	else:
		return Effect.CHAOS


func yellow_specifics(mid_rune, final_rune) -> int:
	if mid_rune == Rune.COLOR.ORANGE && final_rune == Rune.COLOR.ORANGE:
		return Effect.YOO
	else:
		return Effect.CHAOS


func purple_specifics(mid_rune, final_rune) -> int:
	if mid_rune == Rune.COLOR.ORANGE && final_rune == Rune.COLOR.GREEN:
		return Effect.POG
	elif mid_rune == Rune.COLOR.YELLOW && final_rune == Rune.COLOR.GREEN:
		return Effect.PYG
	elif mid_rune == Rune.COLOR.ORANGE && final_rune == Rune.COLOR.ORANGE:
		return Effect.POO
	elif mid_rune == Rune.COLOR.RED && final_rune == Rune.COLOR.ORANGE:
		return Effect.PRO
	else:
		return Effect.CHAOS


func orange_specifics(mid_rune, final_rune) -> int:
	if mid_rune == Rune.COLOR.RED && final_rune == Rune.COLOR.GREEN:
		return Effect.ORG
	elif mid_rune == Rune.COLOR.RED && final_rune == Rune.COLOR.BLUE:
		return Effect.ORB
	elif mid_rune == Rune.COLOR.BLUE && final_rune == Rune.COLOR.GREEN:
		return Effect.OBG
	else:
		return Effect.CHAOS


func green_specifics(mid_rune, final_rune) -> int:
	if mid_rune == Rune.COLOR.ORANGE && final_rune == Rune.COLOR.BLUE:
		return Effect.GOB
	else:
		return Effect.CHAOS


func spell_is_valid(spell_code:Array) -> bool:
	return !spell_code.has(-1) && !spell_code.has(Rune.COLOR.NONE) && spell_code.size() == 3


func is_inside_rgb(rune:int) -> bool:
	return rune == Rune.COLOR.RED || rune == Rune.COLOR.GREEN || rune == Rune.COLOR.BLUE


func is_inside_ypo(rune:int) -> bool:
	return rune == Rune.COLOR.YELLOW || rune == Rune.COLOR.PURPLE || rune == Rune.COLOR.ORANGE
