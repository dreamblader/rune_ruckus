extends KinematicBody2D
class_name Rune

var my_class = "Rune"

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE}
enum SIDE {VERTICAL, HORIZONTAL}

export (COLOR) var color = COLOR.RED

var chains: Array = [[],[]]

var fade_time:float = 0.35
var gravity: float
var column_pos: float

var v_power:int = 1
var h_power:int = 1
var max_power:int = 4

onready var sprite: AnimatedSprite = $AnimatedSprite
onready var detectors: Array = [ $DetectUp, $DetectRigth ]

signal explode
signal touch_the_ground
signal chain_check_finish


func _ready() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	sprite.frame = 0
	column_pos = snap_x
	poke()


func poke() -> void:
	move_and_slide(Vector2(), Vector2(0,-1))


func _process(delta: float) -> void:
	if visible && !is_on_floor():
		move_and_slide(Vector2(0, gravity), Vector2(0,-1))
		position.x = column_pos
	elif visible && is_on_floor():
		emit_signal("touch_the_ground")


func init_chain_check() -> void:
	for side in SIDE.values():
		check_chain(side, [self])
	v_power = chains[SIDE.VERTICAL].size()
	h_power = chains[SIDE.HORIZONTAL].size()


func check_chain(at_side:int, chain:Array) -> Array:
	var my_chain: Array = self.chains[at_side]
	if my_chain.empty():
		my_chain.append_array(chain) 
		var collider = detect_body(at_side)
		if is_chainable_rune(collider):
			var next_rune = collider as Rune
			my_chain.append(next_rune)
			var result = next_rune.check_chain(at_side, my_chain)
			my_chain.clear()
			my_chain.append_array(result)
	else:
		var root = chain[0]
		if !my_chain.has(root):
			#TODO PROBABLY THIS PART IS NOT WORKING
			my_chain.pop_front() 
			chain.append_array(my_chain)
			var updated_chain = chain
			for rune in my_chain:
				rune.update_chain(at_side, updated_chain)
			update_chain(at_side, updated_chain)
	
	return my_chain


func detect_body(at_side:int) -> Object:
	var detector: RayCast2D = detectors[at_side]
	detector.force_raycast_update()
	return detector.get_collider()


func is_chainable_rune(body) -> bool:
	return body != null && body.get_class() == my_class && body.color == self.color


func update_chain(at_side:int, new_chain:Array) -> void:
	chains[at_side].clear()
	chains[at_side].append_array(new_chain)


func snap_position() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	position = Vector2(snap_x, position.y)


func explode() -> void:
	var power = max(v_power, h_power)
	prints("I AM ", self, "MY CHAIN IS:", chains, "GOING TO EXPLODE")
	sprite.frame = min(power-1, max_power-1)
	
	if power >= max_power:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0, fade_time).set_trans(Tween.TRANS_SINE)
		tween.connect("finished", self, "gone")
		emit_signal("explode")
	
	reset_chains()


func reset_chains() -> void:
	for chain in chains:
		chain.clear()


func get_class() -> String:
	return my_class

func gone() -> void:
	queue_free()
