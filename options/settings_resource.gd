extends Resource
class_name Settings

enum Section {VIDEO, AUDIO, CONTROLS}

# VIDEO
var fullscreen: bool = OS.is_window_fullscreen() setget set_fullscreen
var resolution:Vector2 = OS.get_window_size() setget set_resolution
var vsync: bool = OS.is_vsync_enabled() setget set_vsync
# AUDIO
var mute: bool = false setget set_mute
var masterVolumeDb: float = 0.0 setget set_masterVolumeDb
var musicVolumeDb: float = 0.0 setget set_musicVolumeDb
var sfxVolumeDb: float = 0.0 setget set_sfxVolumeDb
var voiceVolumeDb: float = 0.0 setget set_voiceVolumeDb
# CONTROLS
var controlType : int = 0 # 0 = Keyboard | 1 = Controller 
var controllerInputs: Dictionary = {} setget set_controllerInputs
var keyboardInputs: Dictionary = {} setget set_keyboardInputs

#####
var audio_mute_treshold:float = -50.0


func set_fullscreen(new_value):
	fullscreen = new_value
	if OS.is_window_fullscreen() != fullscreen:
		OS.set_window_fullscreen(fullscreen)


func set_resolution(new_value):
	resolution = new_value
	if OS.get_window_size() != resolution:
		OS.set_window_size(resolution)


func set_vsync(new_value):
	vsync = new_value
	if OS.is_vsync_enabled() != vsync:
		OS.set_use_vsync(vsync)


func set_mute(new_value):
	mute = new_value
	if AudioServer.is_bus_mute(0) != mute:
		AudioServer.set_bus_mute(0, mute)


func set_masterVolumeDb(new_value):
	masterVolumeDb = new_value
	if AudioServer.get_bus_volume_db(0) != masterVolumeDb:
		AudioServer.set_bus_volume_db(0, masterVolumeDb)
		AudioServer.set_bus_mute(0, get_mute_flag(masterVolumeDb))


func set_musicVolumeDb(new_value):
	musicVolumeDb = new_value
	if AudioServer.get_bus_volume_db(1) != musicVolumeDb:
		AudioServer.set_bus_volume_db(1, musicVolumeDb)
		AudioServer.set_bus_mute(1, get_mute_flag(musicVolumeDb))


func set_sfxVolumeDb(new_value):
	sfxVolumeDb = new_value
	if AudioServer.get_bus_volume_db(2) != sfxVolumeDb:
		AudioServer.set_bus_volume_db(2, sfxVolumeDb)
		AudioServer.set_bus_mute(2, get_mute_flag(sfxVolumeDb))


func set_voiceVolumeDb(new_value):
	voiceVolumeDb = new_value
	if AudioServer.bus_count > 3 && AudioServer.get_bus_volume_db(3) != voiceVolumeDb:
		AudioServer.set_bus_volume_db(3, voiceVolumeDb)
		AudioServer.set_bus_mute(3, get_mute_flag(voiceVolumeDb))


func set_controllerInputs(new_value):
	controllerInputs = new_value
	#TODO call InputMap and add values


func set_keyboardInputs(new_value):
	keyboardInputs = new_value
	#TODO call InputMap and add values


func get_mute_flag(db:float) -> bool:
	return db <= audio_mute_treshold


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
