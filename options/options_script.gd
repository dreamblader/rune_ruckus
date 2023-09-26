extends Control

export (Array, NodePath) var options

var resolutions: Array = [Vector2(1920, 1080), Vector2(1280, 720), Vector2(854, 480), Vector2(640, 360), Vector2(426, 240)]
var max_volume_points: int = 10
var volume_max_db: float = 0
var volume_min_db: float = -50
var peg_value: float = 5.0
var menu_index: int = 0
var resolution_index: int = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		move_menu(-1)
	
	if event.is_action_pressed("ui_down"):
		move_menu(1)
	
	if event.is_action_pressed("ui_right"):
		move_option(1)
	
	if event.is_action_pressed("ui_left"):
		move_option(-1)
	
	if event.is_action_pressed("ui_select"):
		select_option()
	
	if event.is_action_pressed("ui_cancel"):
		move_back()


func _ready() -> void:
	select_label()
	get_start_resolution_index(SettingsControl.settings.resolution.x)
	set_all_labels()


func set_all_labels() -> void:
	set_fullscreen_label(SettingsControl.settings.fullscreen)
	set_resolution_label(SettingsControl.settings.resolution)
	set_master_volume_label(SettingsControl.settings.masterVolumeDb)
	set_music_volume_label(SettingsControl.settings.musicVolumeDb)
	set_sfx_volume_label(SettingsControl.settings.sfxVolumeDb)


func get_start_resolution_index(resolution_width:float) -> void:
	for index in range(resolutions.size()):
		if resolution_width >= resolutions[index].x:
			resolution_index = index
			return
		elif index == resolutions.size()-1:
			resolution_index = index


func select_label() -> void:
	var selected_label: Label = get_node(options[menu_index])
	selected_label.add_color_override("font_color", Color(1,0,0))


func deselect_label() -> void:
	var deselected_label: Label = get_node(options[menu_index])
	deselected_label.remove_color_override("font_color")


func move_menu(value:int) -> void:
	deselect_label()
	menu_index_change(value)
	
	if menu_index == 1 && SettingsControl.settings.fullscreen:
		menu_index_change(value)
	
	select_label()


func menu_index_change(value:int):
	menu_index = (menu_index + value) % options.size()
	if menu_index < 0:
		menu_index = options.size()-1


func move_option(value:int) -> void:
	match menu_index:
		0:
			switch_fullscreen()
		1:
			move_resolutions(value)
		2:
			move_volume_slide(0, value*peg_value)
		3:
			move_volume_slide(1, value*peg_value)
		4: 
			move_volume_slide(2, value*peg_value)


func set_fullscreen_label(flag:bool) -> void:
	var label: Label = $Menu/Main/Video/Fullscreen 
	var value: String = "On" if flag else "Off"
	label.text = "Fullscreen: " + value
	enable_resolution_label(flag)


func set_resolution_label(resolution:Vector2) -> void:
	var label: Label = $Menu/Main/Video/Resolution 
	var value: String = String(resolution.x) + " x " + String(resolution.y)
	label.text = "Resolution: " + value


func enable_resolution_label(enable:bool) -> void:
	var label: Label = $Menu/Main/Video/Resolution 
	if enable:
		label.add_color_override("font_color", Color(0.08, 0.08, 0.08))
	else:
		label.remove_color_override("font_color")


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
	var volume_peg: int = clamp((value-volume_min_db)/peg_value, 0, max_volume_points) 
	var result: String
	for i in range(max_volume_points):
		result += "|" if i < volume_peg else "."
	return result


func select_option() -> void:
	match menu_index:
		0:
			switch_fullscreen()
		5:
			back_to_default()
		6:
			move_back()


func switch_fullscreen() -> void:
	var new_flag: bool = !SettingsControl.settings.fullscreen
	SettingsControl.settings.fullscreen = new_flag
	set_fullscreen_label(new_flag)


func move_resolutions(value:int) -> void:
	if !SettingsControl.settings.fullscreen:
		resolution_index = (resolution_index + value) % resolutions.size()
		if resolution_index < 0:
			resolution_index = resolutions.size()-1
		var new_resolution = resolutions[resolution_index]
		SettingsControl.settings.resolution = new_resolution
		set_resolution_label(new_resolution)


func move_volume_slide(audio_id: int, value:int) -> void:
	var volume_to_update: float
	
	match audio_id:
		0:
			volume_to_update = SettingsControl.settings.masterVolumeDb
			SettingsControl.settings.masterVolumeDb =  clamp(volume_to_update+value, -max_volume_points*peg_value, 0)
			set_master_volume_label(SettingsControl.settings.masterVolumeDb)
		1:
			volume_to_update = SettingsControl.settings.musicVolumeDb
			SettingsControl.settings.musicVolumeDb =  clamp(volume_to_update+value, -max_volume_points*peg_value, 0)
			set_music_volume_label(SettingsControl.settings.musicVolumeDb)
		2:
			volume_to_update = SettingsControl.settings.sfxVolumeDb
			SettingsControl.settings.sfxVolumeDb =  clamp(volume_to_update+value, -max_volume_points*peg_value, 0)
			set_sfx_volume_label(SettingsControl.settings.sfxVolumeDb)


func back_to_default() -> void:
	resolution_index = 0
	SettingsControl.settings.fullscreen = false
	SettingsControl.settings.resolution = Vector2(1920, 1080)
	SettingsControl.settings.masterVolumeDb = 0.0
	SettingsControl.settings.musicVolumeDb = 0.0
	SettingsControl.settings.sfxVolumeDb = 0.0
	set_all_labels()


func move_back() -> void:
	get_tree().change_scene("res://game_scene.tscn")
