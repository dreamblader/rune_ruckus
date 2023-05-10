extends Control

export (String, MULTILINE) var text
export (float) var text_show_time

onready var label:RichTextLabel = $RichTextLabel
onready var animation:AnimationPlayer = $AnimationPlayer

var tween:SceneTreeTween


func _ready() -> void:
	label.text = text
	#update_size()


func update_size() -> void:
	label.rect_min_size = label.get_font("normal_font").get_string_size(text)
	print(label.rect_min_size)


func appear() -> void:
	tween = get_tree().create_tween()
	tween.set_pause_mode(pause_mode)
	animation.play("hover")
	tween.tween_property(label, "visible_characters", text.length(), text_show_time)


func force_appear() -> void:
	if tween != null:
		tween.kill()
	animation.play("hover")
	label.visible_characters = -1


func disappear() -> void:
	tween = get_tree().create_tween()
	animation.play("RESET")
	tween.tween_property(label, "visible_characters", 0, text_show_time)
