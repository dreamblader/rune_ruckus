extends MarginContainer

enum LockType {PRIMARY, PURPLE, GREEN, ORANGE}

export (StreamTexture) var red_symbol
export (StreamTexture) var blue_symbol
export (StreamTexture) var yellow_symbol
export (StreamTexture) var green_symbol
export (StreamTexture) var purple_symbol
export (StreamTexture) var orange_symbol
export (SpriteFrames) var lock

export (Rune.COLOR) var my_symbol = -1 setget change_symbol
export (LockType) var my_lock

onready var symbol:TextureRect = $Label


func _ready() -> void:
	get_lock()


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


func get_lock() -> void:
	match my_lock:
		LockType.ORANGE:
			symbol.texture = lock.get_frame("default", 0)
		LockType.PURPLE:
			symbol.texture = lock.get_frame("default", 1)
		LockType.GREEN:
			symbol.texture = lock.get_frame("default", 2)
		LockType.PRIMARY:
			symbol.texture = lock.get_frame("default", 3)


func yeet_symbol() -> void:
	#TODO: FUTURE - add tween to explode the symbol/lock out of this panel (when spell is wrong/ unlock panel)
	pass


func consume_symbol() -> void:
	#TODO: FUTURE - add tween to fade symbol (when spell is OK)
	pass


func shake_lock() -> void:
	#TODO: check if locked and then shake it
	pass
