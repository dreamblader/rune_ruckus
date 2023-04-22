extends MarginContainer

export (StreamTexture) var red_symbol
export (StreamTexture) var blue_symbol
export (StreamTexture) var yellow_symbol

export (Rune.COLOR) var my_symbol = -1 setget change_symbol

onready var symbol:TextureRect = $Label


func _ready() -> void:
	change_symbol(my_symbol)


func unlock_block() -> void:
	my_symbol = Rune.COLOR.NONE
	change_symbol(my_symbol)


func change_symbol(new_symbol:int) -> void:
	if my_symbol >= 0:
		my_symbol = new_symbol
		match new_symbol:
			Rune.COLOR.RED:
				symbol.texture = red_symbol
			Rune.COLOR.BLUE:
				symbol.texture = blue_symbol
			Rune.COLOR.YELLOW:
				symbol.texture = yellow_symbol
			_:
				symbol.texture = null
