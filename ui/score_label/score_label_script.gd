extends Panel

@onready var label = $MarginContainer/Label

func set_text(value:String) -> void:
	label.text = value


func set_font_color(color:Color) -> void:
	label.add_theme_color_override("font_color", color)
