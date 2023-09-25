extends Control

export (Array, NodePath) var options

var resolutions: Array = [Vector2(1920, 1080), Vector2(1280, 720), Vector2(854, 480), Vector2(640, 360), Vector2(426, 240)]
var max_volume_points: int = 10
var volume_max_db: float = 0
var volume_min_db: float = -50
var menu_index: int = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		move_menu(-1)
	
	if event.is_action_pressed("ui_down"):
		move_menu(1)
	
	if event.is_action("ui_right"):
		move_option(1)
	
	if event.is_action("ui_left"):
		move_option(-1)
	
	if event.is_action("ui_select"):
		select_option()
	
	if event.is_action("ui_cancel"):
		move_back()


func _ready() -> void:
	select_label()
	# TODO settings is being null????
	set_fullscreen_label(SettingsControl.settings.fullscreen)
	set_resolution_label(SettingsControl.settings.resolution)
	set_master_volume_label(SettingsControl.settings.masterVolumeDb)
	set_music_volume_label(SettingsControl.settings.musicVolumeDb)
	set_sfx_volume_label(SettingsControl.settings.sfxVolumeDb)


func select_label() -> void:
	var selected_label: Label = get_node(options[menu_index])
	selected_label.add_color_override("font_color", Color(1,0,0))


func deselect_label() -> void:
	var deselected_label: Label = get_node(options[menu_index])
	deselected_label.remove_color_override("font_color")


func move_menu(value:int) -> void:
	deselect_label()
	
	menu_index = (menu_index + value) % options.size()
	if menu_index < 0:
		menu_index = options.size()-1
	
	select_label()


func move_option(value:int) -> void:
	pass


func set_fullscreen_label(flag:bool) -> void:
	var label: Label = $Menu/Main/Video/Fullscreen 
	var value: String = "On" if flag else "Off"
	label.text = "Fullscreen: " + value


func set_resolution_label(resolution:Vector2) -> void:
	var label: Label = $Menu/Main/Video/Resolution 
	var value: String = String(resolution.x) + " x " + String(resolution.y)
	label.text = "Resolution: " + value


func set_master_volume_label(dbValue:float) -> void:
	var label: Label = $Menu/Main/Audio/Master
	label.text = "Master Volume: " + get_volume_peg_calculation(dbValue)


func set_music_volume_label(dbValue:float) -> void:
	var label: Label = $Menu/Main/Audio/Music
	label.text = "Music Volume: " + get_volume_peg_calculation(dbValue)


func set_sfx_volume_label(dbValue:float) -> void:
	var label: Label = $Menu/Main/Audio/Sounds
	label.text = "Sounds Volume: " + get_volume_peg_calculation(dbValue)


func get_volume_peg_calculation(value:float) -> String:
	var volume_peg: int = clamp((value-volume_min_db)/5, 0, max_volume_points) 
	var result: String
	for i in range(max_volume_points):
		result += "|" if i < volume_peg else "."
	return result


func select_option() -> void:
	match menu_index:
		5:
			back_to_default()
		6:
			move_back()
		_:
			pass


func back_to_default() -> void:
	pass


func move_back() -> void:
	get_tree().change_scene("res://game_scene.tscn")
