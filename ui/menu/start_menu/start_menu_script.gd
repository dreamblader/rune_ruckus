extends Node2D

@export var min_glow_wait: float
@export var max_glow_wait: float

@onready var title:AnimatedSprite2D = $AnimatedSprite2D
@onready var timer:Timer = $Timer

signal option_selected(option)

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var tween:Tween
var label_snapshot_pos_y:float

var lock_control:bool = false
var selected_index:int = 0
var history_index:int = -1
var options: Array[RuneTablet] = []

enum MENU_OPTIONS {START, SPELLBOOK, LEADERBOARD, OPTIONS, CREDITS, QUIT}


func _input(event: InputEvent) -> void:
	if self.visible && !lock_control:
		if event.is_action_pressed("ui_up"):
			selected_index = selected_index-1 if selected_index > 0 else options.size()-1
			update_menu_selection()
			add_index_to_history()
		
		if event.is_action_pressed("ui_down"):
			selected_index = (selected_index+1) % options.size()
			update_menu_selection()
			add_index_to_history()
		
		if event.is_action_pressed("ui_select"):
			on_option_selected()


func _ready() -> void:
	var vbox_childs = $Content/VBoxContainer.get_children()
	options.assign(vbox_childs)
	update_menu_selection()
	add_index_to_history()
	rng.randomize()


func set_start_menu() -> void:
	selected_index = 0
	lock_control = false


func update_menu_selection() -> void:
	var selected_button:RuneTablet = get_option(selected_index)
	var before_button:RuneTablet = get_option(history_index)
	if before_button != null:
		before_button.deselect()
	selected_button.select()


func on_option_selected() -> void:
	lock_control = true
	var confirm_button = get_option(selected_index)
	confirm_button.confirm()
	select_start_menu()


func menu_gone() -> void:
	self.visible = false
	lock_control = false
	emit_signal("option_selected", "start")


func start_game() -> void:
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(menu_gone)


func select_start_menu() -> void:
	match selected_index:
		MENU_OPTIONS.START:
			start_game()
		MENU_OPTIONS.SPELLBOOK:
			pass
		MENU_OPTIONS.LEADERBOARD:
			pass
		MENU_OPTIONS.OPTIONS:
			emit_signal("option_selected", "options")
		MENU_OPTIONS.CREDITS:
			pass
		MENU_OPTIONS.QUIT: #OPTIONS
			get_tree().quit(0)
		_:
			push_error("Selected Index: "+str(selected_index)+" out of bounds @"+name)


func _on_AnimatedSprite_animation_finished() -> void:
	timer.wait_time = rng.randf_range(min_glow_wait, max_glow_wait)
	timer.start()
	title.stop()


func _on_Timer_timeout() -> void:
	title.play("default")
	

func add_index_to_history() -> void:
	history_index = selected_index


func get_option(index:int) -> RuneTablet:
	if index < 0 || index > options.size():
		return null
	return options[index]
