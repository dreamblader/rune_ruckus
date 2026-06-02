extends Node2D

@export var min_glow_wait: float
@export var max_glow_wait: float

@onready var title:AnimatedSprite2D = %AnimatedSprite2D
@onready var timer:Timer = %Timer
@onready var starter_button = %START
@onready var menu_container = %VBoxContainer

signal option_selected(option)

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var tween:Tween
var label_snapshot_pos_y:float

enum MENU_OPTIONS {START, SPELLBOOK, LEADERBOARD, OPTIONS, CREDITS, QUIT}


func _ready() -> void:
	starter_button.grab_focus()
	rng.randomize()


func lock_menu_controls() -> void:
	menu_container.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED


func menu_gone() -> void:
	self.visible = false
	emit_signal("option_selected", "start")


func start_game() -> void:
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(menu_gone)


func _on_AnimatedSprite_animation_finished() -> void:
	timer.wait_time = rng.randf_range(min_glow_wait, max_glow_wait)
	timer.start()
	title.stop()


func _on_Timer_timeout() -> void:
	title.play("default")


func _on_start_selected() -> void:
	lock_menu_controls()
	start_game()


func _on_spellbook_selected() -> void:
	lock_menu_controls()
	pass # Replace with function body.


func _on_leaderboard_selected() -> void:
	lock_menu_controls()
	pass # Replace with function body.


func _on_options_selected() -> void:
	lock_menu_controls()
	emit_signal("option_selected", "options")


func _on_credits_selected() -> void:
	lock_menu_controls()
	pass # Replace with function body.


func _on_quit_selected() -> void:
	lock_menu_controls()
	get_tree().quit(0)
