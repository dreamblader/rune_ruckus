extends Control

@export var next_scene: PackedScene
@onready var splash_animation = $AnimationPlayer


func _ready() -> void:
	splash_animation.play("splash")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "splash":
		get_tree().change_scene_to_packed(next_scene)
