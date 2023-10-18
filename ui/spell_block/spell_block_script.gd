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

onready var symbol:Sprite = $Sprite
onready var animation:AnimationPlayer = $AnimationPlayer

var symbol_is_visible:bool = true

func _ready() -> void:
	get_lock()


func unlock_block() -> void:
	yeet_symbol()


func cast_spell(valid_spell:bool) -> void:
	if my_symbol < 0:
		shake_lock()
	elif valid_spell:
		consume_symbol()
	else:
		yeet_symbol()


func change_symbol(new_symbol:int) -> void:
	if my_symbol >= 0:
		my_symbol = new_symbol
		
		if my_symbol != Rune.COLOR.NONE && symbol_is_visible:
			disappear_symbol()
			return
		
		match new_symbol:
			Rune.COLOR.RED:
				symbol.texture = red_symbol
			Rune.COLOR.BLUE:
				symbol.texture = blue_symbol
			Rune.COLOR.YELLOW:
				symbol.texture = yellow_symbol
			_:
				symbol.texture = null
		
		appear_symbol()
	else:
		shake_lock()


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
	my_symbol = Rune.COLOR.NONE
	animation.play("yeet")


func disappear_symbol() -> void:
	symbol_is_visible = false
	animation.play("disappear")


func appear_symbol() -> void:
	symbol_is_visible = true
	animation.play("appear")


func consume_symbol() -> void:
	my_symbol = Rune.COLOR.NONE
	animation.play("consume")


func shake_lock() -> void:
	animation.play("shake")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"yeet", "consume", "disappear":
			symbol.rotation_degrees = 0
			change_symbol(my_symbol)
