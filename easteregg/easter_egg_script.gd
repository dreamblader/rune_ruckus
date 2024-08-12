extends Node2D

@onready var dialog_text_label: Label = $Talk_Balloon/PanelContainer/Label

enum EasterEggCall {YOO, OBG}


var ty_text: String = "Thank You For Playing!"
var yoo_text: String = "Yoooooooooooooo!!!"


func call_easter_egg(call_type: EasterEggCall) -> void:
	dialog_text_label.visible_characters = 0
	match  call_type:
		EasterEggCall.YOO:
			dialog_text_label.text = yoo_text
		EasterEggCall.OBG:
			dialog_text_label.text = ty_text
		_:
			dialog_text_label.text = "WHAT?"
	start_typing_animation()
	move_me()


func start_typing_animation() -> void:
	var tween = create_tween()
	var duration:float = 1.5
	tween.tween_property(dialog_text_label, "visible_characters", dialog_text_label.text.length(), duration)


func move_me() -> void:
	var offset_x: float = 160
	var offset_y:float = 120
	var tween = create_tween()
	var duration:float = 5
	#TODO
	#tween.tween_property(self, "position", text.length(), text_show_time)
