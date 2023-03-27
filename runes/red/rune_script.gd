extends KinematicBody2D
class_name Rune

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE}

export (COLOR) var color

var gravity: float

var max_power:int = 4
var v_power:int = 1
var h_power:int = 1

onready var sprite: AnimatedSprite = $AnimatedSprite

signal explode

func _ready() -> void:
	sprite.frame = 0


func _process(delta: float) -> void:
		var collide: KinematicCollision2D = move_and_collide(Vector2(0, gravity))
		if collide != null:
			check_collision(collide)


func check_collision(collide: KinematicCollision2D) -> void:
	var collide_class: String = collide.get_class()


func get_power() -> float:
	return max(v_power, h_power)


func explode() -> void:
	if get_power() >= max_power:
		emit_signal("explode")
		queue_free()
