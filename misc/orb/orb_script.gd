extends Node2D

onready var animation = $AnimationPlayer
onready var sprite = $OrbSprite

var color:int = -1


func _draw() -> void:
	draw_circle(Vector2(), 3.0, get_color()+Color(1,1,1))


func _ready() -> void:
	animation.play("orb_wiggle")
	set_color()


func set_color() -> void:
	var my_material = sprite.material as ShaderMaterial
	var recolor = 	my_material.set_shader_param("recolor", get_color())


func get_color() -> Color:
	match color:
		Rune.COLOR.RED:
			return Color(1,0,0)
		Rune.COLOR.YELLOW:
			return Color(1,1,0)
		Rune.COLOR.BLUE:
			return Color(0,0,1)
		_:
			return Color(1,1,1)
