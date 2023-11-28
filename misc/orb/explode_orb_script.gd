extends Node2D

onready var area: Area2D = $Area2D


func _ready() -> void:
	scale = Vector2()
	trigger()


func trigger() -> void:
	var explosion_time = 1.0
	var lingering_time = 0.5
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1,1), explosion_time/2)
	tween.parallel().tween_property(self, "modulate", Color(1,1,1), (explosion_time/2)+lingering_time)
	tween.tween_callback(self, "destroy_runes")
	tween.tween_property(self, "modulate", Color(0,0,0), explosion_time/2).set_delay(lingering_time)
	tween.parallel().tween_property(self, "scale", Vector2(0,0), explosion_time/2).set_delay(lingering_time)


func destroy_runes() -> void:
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.get_class() == Rune.my_class:
			body.queue_free()
