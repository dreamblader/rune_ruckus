extends Control

@export_multiline var text: String
@export var text_show_time: float

@onready var label:RichTextLabel = $RichTextLabel
@onready var animation:AnimationPlayer = $AnimationPlayer

var tween:Tween


func _ready() -> void:
	label.text = text
	label.visible_ratio = 0
	#update_size()


func update_size() -> void:
	label.custom_minimum_size = label.get_font("normal_font").get_string_size(text)


func appear() -> void:
	tween = create_tween()
	animation.play("hover")
	tween.tween_property(label, "visible_ratio", 1, text_show_time)


func force_appear() -> void:
	if tween != null:
		tween.kill()
	animation.play("hover")
	label.visible_characters = -1


func disappear() -> void:
	tween = get_tree().create_tween()
	animation.play("RESET")
	tween.tween_property(label, "visible_characters", 0, text_show_time)
