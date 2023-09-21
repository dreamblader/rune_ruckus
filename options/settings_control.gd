extends Node

var settings: Settings
var PATH: String = "user://settings.cfg"

#KEYs
var fullscreen_key:String = "fullscreen"
var resolution_key:String = "resolution"
var vsync_key:String = "vsync"
var mute_key:String = "mute"
var masterVolumeDb_key:String = "masterVolumeDb"
var musicVolumeDb_key:String = "musicVolumeDb"
var sfxVolumeDb_key:String = "sfxVolumeDb"
var voiceVolumeDb_key:String = "voiceVolumeDb"
var controlType_key:String = "controlType"
var controllerInputs_key:String = "controllerInputs"
var keyboardInputs_key:String = "keyboardInputs"


func _ready() -> void:
	settings = Settings.new()
	load_settings()
	#print(InputMap.get_actions()) # get actions name
	#print(InputMap.get_action_list("drop"))


func load_settings() -> void:
	var config_file = ConfigFile.new()
	if config_file.load(PATH) != OK:
		set_config_settings(config_file)
		config_file.save(PATH)
	else:
		prints(config_file, config_file.get_sections())
		settings = change_config_settings(config_file)


func change_config_settings(config:ConfigFile) -> void:
	settings.fullscreen = config.get_value(Settings.Section.keys()[Settings.Section.VIDEO], fullscreen_key)
	settings.resolution = config.get_value(Settings.Section.keys()[Settings.Section.VIDEO], resolution_key)
	settings.vsync = config.get_value(Settings.Section.keys()[Settings.Section.VIDEO], vsync_key)
	settings.mute = config.get_value(Settings.Section.keys()[Settings.Section.AUDIO], mute_key)
	settings.masterVolumeDb = config.get_value(Settings.Section.keys()[Settings.Section.AUDIO], masterVolumeDb_key)
	settings.musicVolumeDb = config.get_value(Settings.Section.keys()[Settings.Section.AUDIO], musicVolumeDb_key)
	settings.sfxVolumeDb = config.get_value(Settings.Section.keys()[Settings.Section.AUDIO], sfxVolumeDb_key)
	settings.voiceVolumeDb = config.get_value(Settings.Section.keys()[Settings.Section.AUDIO], voiceVolumeDb_key)
	settings.controlType = config.get_value(Settings.Section.keys()[Settings.Section.CONTROLS], controlType_key)
	settings.controllerInputs = config.get_value(Settings.Section.keys()[Settings.Section.CONTROLS], controllerInputs_key)
	settings.keyboardInputs = config.get_value(Settings.Section.keys()[Settings.Section.CONTROLS], keyboardInputs_key)


func set_config_settings(config:ConfigFile) -> void:
	config.set_value(Settings.Section.keys()[Settings.Section.VIDEO], fullscreen_key, settings.fullscreen)
	config.set_value(Settings.Section.keys()[Settings.Section.VIDEO], resolution_key, settings.resolution)
	config.set_value(Settings.Section.keys()[Settings.Section.VIDEO], vsync_key, settings.vsync)
	config.set_value(Settings.Section.keys()[Settings.Section.AUDIO], mute_key, settings.mute)
	config.set_value(Settings.Section.keys()[Settings.Section.AUDIO], masterVolumeDb_key, settings.masterVolumeDb)
	config.set_value(Settings.Section.keys()[Settings.Section.AUDIO], musicVolumeDb_key, settings.musicVolumeDb)
	config.set_value(Settings.Section.keys()[Settings.Section.AUDIO], sfxVolumeDb_key, settings.sfxVolumeDb)
	config.set_value(Settings.Section.keys()[Settings.Section.AUDIO], voiceVolumeDb_key, settings.voiceVolumeDb)
	config.set_value(Settings.Section.keys()[Settings.Section.CONTROLS], controlType_key, settings.controlType)
	config.set_value(Settings.Section.keys()[Settings.Section.CONTROLS], controllerInputs_key, settings.controllerInputs)
	config.set_value(Settings.Section.keys()[Settings.Section.CONTROLS], keyboardInputs_key, settings.keyboardInputs)


func save_settings() -> void:
	var config_file = ConfigFile.new()
	set_config_settings(config_file)
	prints("DEBUG:", config_file.get_sections())
	config_file.save(PATH)


# CONTROL EXAMPLE
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
