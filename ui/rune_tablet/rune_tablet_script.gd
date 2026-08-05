extends MarginContainer
class_name RuneTablet

@onready var tablet = $NinePatchRect
@onready var text = $MarginContainer/Label
@onready var accept_sound = $Accept
@onready var move_sound = $Move

@export var display_text: String = ""
@export var glow_color: Color = Color(1,0,0)

signal selected

var is_selected = false
var text_material:ShaderMaterial
var tablet_material: ShaderMaterial


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && self.has_focus():
			confirm()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select") && self.has_focus():
		confirm()
		


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
	move_sound.volume_db = -80
	release_focus()
	accept_sound.play()
	text_material.set_shader_parameter("full_glow", true)
	tablet_material.set_shader_parameter("full_glow", true)
	#move_sound.volume_db = 0
	selected.emit()


func _on_focus_entered() -> void:
	select()


func _on_focus_exited() -> void:
	deselect()


func _on_mouse_entered() -> void:
	grab_focus()
