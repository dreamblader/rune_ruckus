extends KinematicBody2D
class_name Rune

var my_class = "Rune"

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE}

export (COLOR) var color = COLOR.RED

var edges: Array = []

var gravity: float
var column_pos: float

var max_power:int = 4
var v_power:int = 1
var h_power:int = 1

var visited:bool = false

onready var sprite: AnimatedSprite = $AnimatedSprite
onready var detectors: Array = [ $DetectUp, $DetectRigth, $DetectDown, $DetectLeft ]

signal explode


func _ready() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	sprite.frame = 0
	column_pos = snap_x
	edges.resize(detectors.size())
	move_and_slide(Vector2(), Vector2(0,-1))


func _process(delta: float) -> void:
	if visible && !is_on_floor():
		move_and_slide(Vector2(0, gravity), Vector2(0,-1)) #slide is creating weird bugs
		position.x = column_pos


func check_edges() -> void:
	var index = 0
	for d in detectors:
		var detector = d as RayCast2D
		#TODO force raycast need to wait gravity act first
		detector.force_raycast_update()
		var collider = detector.get_collider()
		if collider != null && collider.get_class() == my_class:
			prints(self.name,"--->", collider.name, "AT", index)
		index += 1


func snap_position() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	position = Vector2(snap_x, position.y)


func reset_powers() -> void:
	v_power = 1
	h_power = 1


func explode() -> void:
	var power = max(v_power, h_power)
	sprite.frame = min(power-1, max_power-1)
	
	if power >= max_power:
		emit_signal("explode")
		queue_free()
	
	visited = false
	reset_powers()


func get_class() -> String:
	return my_class
