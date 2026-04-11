extends Node2D

@onready var animation = $AnimationPlayer
var controller_mode = false


func start_record(rank:int, score:float, spells_count:Dictionary, game_time:float) -> void:
	animation.play("enter_end_mode")
	self.visible = true
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
