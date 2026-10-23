extends HBoxContainer

@onready var left_icon = %L
@onready var text_label = %Text
@onready var right_icon = %R

@export var options: Array[String]

var current_index = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") && self.has_focus():
		move_index(-1)
	if event.is_action_pressed("ui_right") && self.has_focus():
		move_index(1)


func _ready() -> void:
	if options.is_empty():
		self.visible = false
		self.focus_mode = Control.FOCUS_NONE
		return
	
	if options.size() == 1:
		right_icon.visible = false
		left_icon.visible = false
	
	update_spinner()


func move_index(value:int) -> void:
	var new_index = current_index + value
	if new_index >= 0 && new_index < options.size():
		current_index = new_index
		update_spinner()


func update_spinner() -> void:
	text_label.text = options[current_index]
	left_icon.modulate.a = 0 if current_index == 0 else 1
	right_icon.modulate.a = 0 if current_index == options.size()-1 else 1


func _on_r_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT && self.has_focus() && right_icon.modulate.a == 1:
				move_index(1)


func _on_l_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT && self.has_focus() && right_icon.modulate.a == 1:
				move_index(-1)


func _on_focus_entered() -> void:
	pass # Replace with function body.


func _on_focus_exited() -> void:
	pass # Replace with function body.
