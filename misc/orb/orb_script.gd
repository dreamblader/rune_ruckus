extends Node2D

onready var animation = $AnimationPlayer
onready var sprite = $OrbSprite

var color:int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("orb_wiggle")
	set_color()


func set_color() -> void:
	var my_material = sprite.material as ShaderMaterial
	var recolor = Color(1,1,1)
	match color:
		Rune.COLOR.RED:
			recolor = Color(1,0,0)
		Rune.COLOR.YELLOW:
			recolor = Color(1,1,0)
		Rune.COLOR.BLUE:
			recolor = Color(0,0,1)
	my_material.set_shader_param("recolor", recolor)
