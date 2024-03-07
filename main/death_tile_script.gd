extends Node2D

@onready var detector:RayCast2D = $Detector
@onready var sprite:Sprite2D = $Sprite2D
@onready var animation:AnimationPlayer = $AnimationPlayer

@export var blink_duration:float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("blink")


func did_u_died() -> bool:
	detector.force_raycast_update()
	var object = detector.get_collider()
	return is_rune(object)


func is_rune(body) -> bool:
	return body != null && body is Rune
