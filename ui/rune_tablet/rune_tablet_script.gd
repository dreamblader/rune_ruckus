extends MarginContainer

@onready var tablet = $NinePatchRect
@onready var text = $MarginContainer/Label

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


func select() -> void:
	text_material.set_shader_parameter("enable", true)
	tablet_material.set_shader_parameter("enable", true)


func deselect() -> void:
	text_material.set_shader_parameter("enable", false)
	tablet_material.set_shader_parameter("enable", false)


func confirm() -> void:
	text_material.set_shader_parameter("full_glow", true)
	tablet_material.set_shader_parameter("full_glow", true)
