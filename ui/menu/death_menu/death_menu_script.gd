extends Menu


func update_menu_selection() -> void:
	var selected_label:Label = get_option_label(selected_index)
	var before_label:Label = get_option_label(history_index)
	if before_label != null:
		before_label.remove_color_override("font_color")
	selected_label.add_color_override("font_color", Color(1,0,0))
	selected_label.add_color_override("font_color", Color(1,0,0))


func on_option_selected() -> void:
	self.lock_control = true
	match selected_index:
		0:
			fade_menu()
		1:
			get_tree().quit(0)


func fade_menu() -> void:
	var fade_time = 0.5
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0, fade_time)
	tween.tween_callback(self, "reset_visibility")
	emit_signal("option_selected", "restart")


func reset_visibility() -> void:
	self.visible = false
	self.lock_control = false
	self.modulate.a = 1
