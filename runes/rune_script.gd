extends KinematicBody2D
class_name Rune

var my_class = "Rune"

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE}
enum SIDE {VERTICAL, HORIZONTAL}

export (COLOR) var color = COLOR.RED

var chains: Array = [[],[]]

var gravity: float
var column_pos: float

var max_power:int = 4

onready var sprite: AnimatedSprite = $AnimatedSprite
onready var detectors: Array = [ $DetectUp, $DetectRigth ]

signal explode
signal touch_the_ground


func _ready() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	sprite.frame = 0
	column_pos = snap_x
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


func check_chain(at_side:int, chain:Array) -> Array:
	var my_chain: Array = chains[at_side]
	
	if my_chain.empty():
		my_chain.append_array(chain)
		var collider = detect_body(at_side)
		#modulate = Color(my_chain.size()/6, my_chain.size()/6, my_chain.size()/6) # VISUAL TEST (REMOVE AFTER)
		if is_chainable_rune(collider):
			var next_rune = collider as Rune
			while next_rune != null && !next_rune.is_on_floor(): #Check if rune is floating 'phantom runes'
				yield(next_rune, "touch_the_ground")
				var real_collider: Object = detect_body(at_side)
				next_rune = real_collider as Rune if is_chainable_rune(real_collider) else null
			if next_rune != null:
				my_chain.append(next_rune)
				my_chain = next_rune.check_chain(at_side, my_chain)
	else:
		var root = chain[0]
		if !my_chain.has(root):
			my_chain.pop_front() #remove duplicate member
			chain.append_array(my_chain)
			var updated_chain = chain
			for rune in my_chain: #Update all old members of chain
				rune.update_chain(at_side, updated_chain)
			my_chain = updated_chain
	
	prints("I AM ", self, "MY CHAIN IS:", my_chain, "AT SIDE:", at_side)
	return my_chain


func detect_body(at_side:int) -> Object:
	var detector: RayCast2D = detectors[at_side]
	detector.force_raycast_update()
	return detector.get_collider()


func is_chainable_rune(body) -> bool:
	return body != null && body.get_class() == my_class && body.color == self.color


func update_chain(at_side:int, new_chain:Array) -> void:
	chains[at_side] = new_chain


func snap_position() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	position = Vector2(snap_x, position.y)


func explode() -> void:
	var power = max(chains[SIDE.VERTICAL].size(), chains[SIDE.HORIZONTAL].size())
	sprite.frame = min(power-1, max_power-1)
	
	if power >= max_power:
		emit_signal("explode")
		queue_free()
	
	reset_chains()


func reset_chains() -> void:
	for chain in chains:
		chain.clear()


func get_class() -> String:
	return my_class
