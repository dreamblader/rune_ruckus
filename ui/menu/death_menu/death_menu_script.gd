extends Menu


func update_menu_selection() -> void:
	var selected_label:Label = get_option_label(selected_index)
	var before_label:Label = get_option_label(history_index)
	if before_label != null:
		before_label.remove_color_override("font_color")
	selected_label.add_color_override("font_color", Color(1,0,0))


func on_option_selected() -> void:
	pass
	#implement here the menu option selection
