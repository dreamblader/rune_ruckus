extends Node
class_name Settings

enum Section {VIDEO, AUDIO, CONTROLS}

signal on_settings_change

# VIDEO
var fullscreen: bool = ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)): set = set_fullscreen
var resolution:Vector2 = get_window().get_size(): set = set_resolution
var vsync: bool = (DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED): set = set_vsync
# AUDIO
var mute: bool = false: set = set_mute
var masterVolumeDb: float = 0.0: set = set_masterVolumeDb
var musicVolumeDb: float = 0.0: set = set_musicVolumeDb
var sfxVolumeDb: float = 0.0: set = set_sfxVolumeDb
var voiceVolumeDb: float = 0.0: set = set_voiceVolumeDb
# CONTROLS
var controlType : int = 0 # 0 = Keyboard | 1 = Controller 
var controllerInputs: Dictionary = {}: set = set_controllerInputs
var keyboardInputs: Dictionary = {}: set = set_keyboardInputs



func set_fullscreen(new_value):
	fullscreen = new_value
	if ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)) != fullscreen:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (fullscreen) else Window.MODE_WINDOWED
		emit_signal("on_settings_change")


func set_resolution(new_value):
	resolution = new_value
	if get_window().get_size() != resolution:
		get_window().set_size(resolution)
		emit_signal("on_settings_change")


func set_vsync(new_value):
	vsync = new_value
	if (DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED) != vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (vsync) else DisplayServer.VSYNC_DISABLED)
		emit_signal("on_settings_change")


func set_mute(new_value):
	mute = new_value
	if AudioServer.is_bus_mute(0) != mute:
		AudioServer.set_bus_mute(0, mute)
		emit_signal("on_settings_change")


func set_masterVolumeDb(new_value):
	masterVolumeDb = new_value
	if AudioServer.get_bus_volume_db(0) != masterVolumeDb:
		AudioServer.set_bus_volume_db(0, masterVolumeDb)
		AudioServer.set_bus_mute(0, get_mute_flag(masterVolumeDb))
		emit_signal("on_settings_change")


func set_musicVolumeDb(new_value):
	musicVolumeDb = new_value
	if AudioServer.get_bus_volume_db(1) != musicVolumeDb:
		AudioServer.set_bus_volume_db(1, musicVolumeDb)
		AudioServer.set_bus_mute(1, get_mute_flag(musicVolumeDb))
		emit_signal("on_settings_change")


func set_sfxVolumeDb(new_value):
	sfxVolumeDb = new_value
	if AudioServer.get_bus_volume_db(2) != sfxVolumeDb:
		AudioServer.set_bus_volume_db(2, sfxVolumeDb)
		AudioServer.set_bus_mute(2, get_mute_flag(sfxVolumeDb))
		emit_signal("on_settings_change")


func set_voiceVolumeDb(new_value):
	voiceVolumeDb = new_value
	if AudioServer.bus_count > 3 && AudioServer.get_bus_volume_db(3) != voiceVolumeDb:
		AudioServer.set_bus_volume_db(3, voiceVolumeDb)
		AudioServer.set_bus_mute(3, get_mute_flag(voiceVolumeDb))
		emit_signal("on_settings_change")


func set_controllerInputs(new_value):
	controllerInputs = new_value
	#TODO call InputMap and add values


func set_keyboardInputs(new_value):
	keyboardInputs = new_value
	#TODO call InputMap and add values


func get_mute_flag(db:float) -> bool:
	return db <= SettingsControl.audio_mute_treshold


# CONTROL EXAMPLE
#print(InputMap.get_actions()) # get actions name
#print(InputMap.get_action_list("drop"))
######
#		for action in config.get_section_keys("input"):
#			# Get the key scancode corresponding to the saved human-readable string
#			scancode = OS.find_scancode_from_string(config.get_value("input", action))
#			# Create a new event object based on the saved scancode
#			event = InputEventKey.new()
#			event.scancode = scancode
#			# Replace old actions by the new one - apparently erasing the old action
#			# works better to get the control buttons properly initialised in the UI
#			# TODO: Handle multiple events per action in a better way
#			for old_event in InputMap.get_action_list(action):
#				if old_event is InputEventKey:
#					InputMap.action_erase_event(action, old_event)
#			InputMap.action_add_event(action, event)
