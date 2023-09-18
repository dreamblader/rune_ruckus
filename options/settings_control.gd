extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(InputMap.get_actions()) # get actions name
	print(InputMap.get_action_list("drop"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

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
