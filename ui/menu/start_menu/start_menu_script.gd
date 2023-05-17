extends Menu

export (float) var min_glow_wait
export (float) var max_glow_wait


onready var title:AnimatedSprite = $AnimatedSprite
onready var timer:Timer = $Timer

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var tween:SceneTreeTween
var label_snapshot_pos_y:float


func _ready() -> void:
	rng.randomize()


func update_menu_selection() -> void:
	var selected_label:Label = get_option_label(selected_index)
	var before_label:Label = get_option_label(history_index)
	if before_label != null:
		reset_label(before_label)
	animate_label(selected_label)


func on_option_selected() -> void:
	lock_control = true
	reset_label(get_option_label(selected_index))
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(self, "menu_gone")


func menu_gone() -> void:
	self.visible = false
	lock_control = false
	match selected_index:
		0:
			emit_signal("option_selected", "start")
		1:
			#TODO ADD ACTUAL STUFF HERE
			emit_signal("option_selected", "start")
		2:
			#TODO ADD ACTUAL STUFF HERE
			emit_signal("option_selected", "start")
		_:
			push_error("Selected Index: "+str(selected_index)+" out of bounds @"+name)


func animate_label(label:Label) -> void:
	label_snapshot_pos_y = label.rect_position.y
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_loops()
	tween.tween_property(label, "rect_position:y", label_snapshot_pos_y+5, 0.5)
	tween.tween_property(label, "rect_position:y", label_snapshot_pos_y-10, 1)
	label.add_color_override("font_color", Color(1,0,0))


func reset_label(label:Label) -> void:
	tween.kill()
	label.rect_position.y = label_snapshot_pos_y
	label.remove_color_override("font_color")


func _on_AnimatedSprite_animation_finished() -> void:
	timer.wait_time = rng.randf_range(min_glow_wait, max_glow_wait)
	timer.start()
	title.stop()


func _on_Timer_timeout() -> void:
	title.play("default")
