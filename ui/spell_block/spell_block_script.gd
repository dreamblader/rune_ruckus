extends MarginContainer

enum LockType {PRIMARY, PURPLE, GREEN, ORANGE}

@export var red_symbol : CompressedTexture2D
@export var blue_symbol : CompressedTexture2D
@export var yellow_symbol : CompressedTexture2D
@export var green_symbol : CompressedTexture2D
@export var purple_symbol : CompressedTexture2D
@export var orange_symbol : CompressedTexture2D
@export var lock : SpriteFrames

@export var my_symbol: int = -1: set = change_symbol
@export var my_lock: LockType

@onready var symbol:Sprite2D = $Sprite2D
@onready var panel: Panel = $Panel
@onready var panel_animation: AnimationPlayer = $Panel/PanelAnimation
@onready var animation:AnimationPlayer = $AnimationPlayer

var symbol_is_visible:bool = true
var locked:bool = true

func _ready() -> void:
	get_lock()


func lock_block() -> void:
	my_symbol = -1
	locked = true
	get_lock()


func unlock_block() -> void:
	yeet_symbol()


func select_block(yes:bool) -> void:
	if yes:
		panel_animation.play("blink")
	else:
		panel_animation.play("RESET")


func cast_spell(valid_spell:bool) -> void:
	if my_symbol < 0:
		shake_lock()
	elif valid_spell:
		consume_symbol()
	else:
		yeet_symbol()


func change_symbol(new_symbol:int) -> void:
	if !locked:
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
			symbol.texture = lock.get_frame_texture("default", 0)
		LockType.PURPLE:
			symbol.texture = lock.get_frame_texture("default", 1)
		LockType.GREEN:
			symbol.texture = lock.get_frame_texture("default", 2)
		LockType.PRIMARY:
			symbol.texture = lock.get_frame_texture("default", 3)


func yeet_symbol() -> void:
	symbol_is_visible = false
	locked = false
	my_symbol = Rune.COLOR.NONE
	animation.play("yeet")


func disappear_symbol() -> void:
	symbol_is_visible = false
	animation.play("disappear")


func appear_symbol() -> void:
	symbol_is_visible = true
	animation.play("appear")


func consume_symbol() -> void:
	symbol_is_visible = false
	my_symbol = Rune.COLOR.NONE
	animation.play("consume")


func shake_lock() -> void:
	animation.play("shake")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"yeet", "consume", "disappear":
			symbol.rotation_degrees = 0
			change_symbol(my_symbol)
