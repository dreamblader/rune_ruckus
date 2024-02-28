extends Node2D

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE}

@export var color: COLOR : set = change_color
@export var red_animation : SpriteFrames
@export var blue_animation : SpriteFrames
@export var yellow_animation : SpriteFrames
@export var green_animation : SpriteFrames
@export var purple_animation : SpriteFrames
@export var orange_animation : SpriteFrames
@export var pivot: bool = false

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	toggle_border(pivot)


func init_sprite() -> void:
	sprite = sprite if sprite != null else $AnimatedSprite2D


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
	material.set_shader_parameter("active", flag)
