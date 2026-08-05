extends Label

var tween: Tween

signal selected

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select") && self.has_focus():
		confirm()


func deselect() -> void:
	if tween != null:
		tween.stop()
		tween = null
	add_theme_color_override("font_outline_color", Color(1,1,1))
	add_theme_constant_override("outline_size", 5) 


func select() -> void:
	tween = create_tween()
	var color_start = Color(0,0,0)
	var color_end = Color(1,0,0)
	add_theme_color_override("font_outline_color", color_start)
	add_theme_constant_override("outline_size", 20)
	tween.tween_property(self,"theme_override_colors/font_outline_color",color_start,1)
	tween.tween_property(self,"theme_override_colors/font_outline_color",color_end,1)
	tween.set_loops()


func confirm() -> void:
	release_focus()
	#accept_sound.play()
	selected.emit()


func _on_focus_entered() -> void:
	select()


func _on_focus_exited() -> void:
	deselect()
