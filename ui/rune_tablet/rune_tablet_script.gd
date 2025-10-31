extends MarginContainer
class_name RuneTablet

@onready var tablet = $NinePatchRect
@onready var text = $MarginContainer/Label
@onready var accept_sound = $Accept
@onready var move_sound = $Move

@export var display_text: String = ""
@export var glow_color: Color = Color(1,0,0)

var is_selected = false
var text_material:ShaderMaterial
var tablet_material: ShaderMaterial


func _ready() -> void:
	text_material = text.material
	tablet_material = tablet.material
	
	text.text = display_text
	
	text_material.set_shader_parameter("glow_color", glow_color)
	tablet_material.set_shader_parameter("glow_color", glow_color)
	tablet_material.set_shader_parameter("animate", false)


func select() -> void:
	text_material.set_shader_parameter("enable", true)
	tablet_material.set_shader_parameter("enable", true)


func deselect() -> void:
	move_sound.play()
	text_material.set_shader_parameter("enable", false)
	tablet_material.set_shader_parameter("enable", false)


func confirm() -> void:
	accept_sound.play()
	text_material.set_shader_parameter("full_glow", true)
	tablet_material.set_shader_parameter("full_glow", true)
