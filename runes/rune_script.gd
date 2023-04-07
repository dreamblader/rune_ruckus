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
signal touch_the_ground


func _ready() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	sprite.frame = 0
	column_pos = snap_x
	edges.resize(detectors.size())
	move_and_slide(Vector2(), Vector2(0,-1))


func _process(delta: float) -> void:
	if visible && !is_on_floor():
		move_and_slide(Vector2(0, gravity), Vector2(0,-1))
		position.x = column_pos
	elif is_on_floor():
		emit_signal("touch_the_ground")


func check_edges() -> void:
	var index = 0
	if !is_on_floor():
		yield(self, "touch_the_ground")
	for d in detectors:
		var detector = d as RayCast2D
		detector.force_raycast_update()
		var collider = detector.get_collider()
		if collider != null && collider.get_class() == my_class:
			prints(self.name,"--->", collider.name, "AT", index)
		index += 1


func link(rune:Rune, position:int) -> void:
	edges.insert(position, rune) 
	add_power(position, 1)
	rune.chain_call(self, position, 1)


func chain_call(caller:Rune, from:int, value:int):
	var opposite_side = from+2 if from < 2 else from-2
	var next_rune = edges[from] # TODO maybe next is unknown yet. Need to reformat. Maybe call detector again?
	edges.insert(opposite_side, caller)
	add_power(from, value)
	if next_rune != null:
		next_rune.chain_call(self, from, 1)


func add_power(position:int, value:int) -> void:
	if position%2 == 0:
		v_power+=value
	else:
		h_power+=value


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
