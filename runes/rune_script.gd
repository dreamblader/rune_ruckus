extends KinematicBody2D
class_name Rune

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE}

export (COLOR) var color = COLOR.RED

var gravity: float

var max_power:int = 4
var v_power:int = 1
var h_power:int = 1

onready var sprite: AnimatedSprite = $AnimatedSprite

signal explode

func _ready() -> void:
	sprite.frame = 0
	move_and_slide(Vector2(), Vector2(0,-1))
	snap_position()


func _process(delta: float) -> void:
	if visible && !is_on_floor():
		move_and_slide(Vector2(0, gravity), Vector2(0,-1)) #slide is creating weird bugs
		snap_position()


func snap_position() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	position = Vector2(snap_x, position.y)


func get_power() -> float:
	return max(v_power, h_power)


func explode() -> void:
	if get_power() >= max_power:
		emit_signal("explode")
		queue_free()
