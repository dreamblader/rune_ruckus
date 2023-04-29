extends Panel

onready var label = $MarginContainer/Label

func set_text(value:String) -> void:
	label.text = value
