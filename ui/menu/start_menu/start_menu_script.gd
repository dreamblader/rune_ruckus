extends Menu

export (float) var min_glow_wait
export (float) var max_glow_wait


onready var title:AnimatedSprite = $AnimatedSprite
onready var timer:Timer = $Timer

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var tween:SceneTreeTween
var label_snapshot_pos_y:float
var menu_layer: int = 0

var start_options: Array
var extra_options: Array


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") && menu_layer == 1:
		set_start_menu()


func _ready() -> void:
	start_options = options.duplicate(true)
	start_extra_options()
	rng.randomize()


func start_extra_options() -> void:
	extra_options.append("Leaderboard")
	extra_options.append("Spells")
	extra_options.append("Credits")
	extra_options.append("Back")


func set_extra_menu() -> void:
	menu_layer = 1
	selected_index = 0
	lock_control = false
	_set_options(extra_options)


func set_start_menu() -> void:
	menu_layer = 0
	selected_index = 0
	lock_control = false
	_set_options(start_options)


func update_menu_selection() -> void:
	var selected_label:Label = get_option_label(selected_index)
	var before_label:Label = get_option_label(history_index)
	if before_label != null:
		reset_label(before_label)
	animate_label(selected_label)


func on_option_selected() -> void:
	lock_control = true
	reset_label(get_option_label(selected_index))
	match menu_layer:
		0:
			select_start_menu()
		1:
			select_extra_menu()
		_:
			push_error("Menu Layer: "+str(menu_layer)+" out of bounds @"+name)


func menu_gone() -> void:
	self.visible = false
	lock_control = false
	emit_signal("option_selected", "start")


func start_game() -> void:
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(self, "menu_gone")


func select_start_menu() -> void:
	match selected_index:
		0:
			start_game()
		1:
			set_extra_menu()
		2:
			emit_signal("option_selected", "options")
		_:
			push_error("Selected Index: "+str(selected_index)+" out of bounds @"+name)


func select_extra_menu() -> void:
	match selected_index:
		0:
			#TODO ADD GO TO LEADERBOARDS HERE
			pass
		1:
			#TODO ADD GO TO SPELL BOOK HERE
			pass
		2:
			#TODO ADD GO TO CREDITS HERE
			pass
		3:
			set_start_menu()
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
