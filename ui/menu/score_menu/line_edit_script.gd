extends LineEdit

func _gui_input(event: InputEvent) -> void:
	if has_focus():
		if event.is_action_pressed("ui_down"):
			find_next_valid_focus().grab_focus()
			get_viewport().set_input_as_handled()
		if event.is_action_pressed("ui_up"):
			find_prev_valid_focus().grab_focus()
			get_viewport().set_input_as_handled()


func _on_focus_entered() -> void:
	caret_column = text.length()
	edit()
