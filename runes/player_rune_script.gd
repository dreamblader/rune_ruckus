extends Node2D

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE}

export (COLOR) var color setget change_color
export (SpriteFrames) var red_animation
export (SpriteFrames) var blue_animation
export (SpriteFrames) var yellow_animation
export (SpriteFrames) var green_animation
export (SpriteFrames) var purple_animation
export (SpriteFrames) var orange_animation
export (bool) var pivot = false

onready var sprite = $AnimatedSprite


func _ready() -> void:
	toggle_border(pivot)


func init_sprite() -> void:
	sprite = sprite if sprite != null else $AnimatedSprite


func change_color(new_color:int) -> void:
	init_sprite()
	match new_color:
		COLOR.RED:
			sprite.frames = red_animation
		COLOR.YELLOW:
			sprite.frames = yellow_animation
		COLOR.BLUE:
			sprite.frames = blue_animation
		COLOR.GREEN:
			sprite.frames = green_animation
		COLOR.PURPLE:
			sprite.frames = purple_animation
		COLOR.ORANGE:
			sprite.frames = orange_animation
		_: #NONE
			push_error("INCORRECT SET COLOR EXCEPTION @ PlayerRune")
	color = new_color


func toggle_border(flag:bool) -> void:
	init_sprite()
	material = sprite.material as ShaderMaterial
	material.set_shader_param("active", flag)
