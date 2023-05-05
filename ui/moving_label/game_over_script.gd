extends CenterContainer

onready var label:RichTextLabel = $RichTextLabel
onready var animation:AnimationPlayer = $AnimationPlayer

var tween:SceneTreeTween

func appear(text_show_time:float) -> void:
	tween = get_tree().create_tween()
	animation.play("hover")
	tween.tween_property(label, "visible_characters", label.text.length(), text_show_time)


func force_appear() -> void:
	if tween != null:
		tween.kill()
	animation.play("hover")
	label.visible_characters = -1
