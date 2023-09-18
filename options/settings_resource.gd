extends Resource

# VIDEO
var fullscreen: bool = OS.is_window_fullscreen
var resolution:Vector2 = OS.get_window_size
var vsync: bool = OS.is_vsync_enabled
# AUDIO
var mute: bool = false
var masterVolumeDb: float = 0.0
var musicVolumeDb: float = 0.0
var sfxVolumeDb: float = 0.0
var voiceVolumeDb: float = 0.0
# CONTROLS
var controlType : int = 0 # 0 = Keyboard | 1 = Controller
var controllerInputs: Dictionary = {}
var keyboardInputs: Dictionary = {}
