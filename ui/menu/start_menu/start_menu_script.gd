extends Menu

export (float) var min_glow_wait
export (float) var max_glow_wait


onready var title:AnimatedSprite = $AnimatedSprite
onready var timer:Timer = $Timer

var rng:RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func update_menu_selection() -> void:
	var selected_label:Label = get_option_label(selected_index)
	var before_label:Label = get_option_label(history_index)
	if before_label != null:
		before_label.remove_color_override("font_color")
	selected_label.add_color_override("font_color", Color(1,0,0))


func on_option_selected() -> void:
	pass


func animate_label(label:Label) -> void:
	# try to make it float
	pass


func reset_label(label:Label) -> void:
	#try to make it stop flaoting
	pass


func _on_AnimatedSprite_animation_finished() -> void:
	timer.wait_time = rng.randf_range(min_glow_wait, max_glow_wait)
	timer.start()
	title.stop()


func _on_Timer_timeout() -> void:
	title.play("default")
