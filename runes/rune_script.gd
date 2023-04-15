extends KinematicBody2D
class_name Rune

var my_class = "Rune"

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE}
enum SIDE {VERTICAL, HORIZONTAL}

export (COLOR) var color = COLOR.RED

var chains: Array = [[],[]]

var fade_time:float
var gravity: float
var column_pos: float

var v_power:int = 1
var h_power:int = 1
var max_power:int = 4

var tween:SceneTreeTween

onready var sprite: AnimatedSprite = $AnimatedSprite
onready var detectors: Array = [ $DetectUp, $DetectRigth ]

signal explode(rune)
signal touch_the_ground


func _ready() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	sprite.frame = 0
	column_pos = snap_x
	poke()


func poke() -> void:
	move_and_slide(Vector2(), Vector2(0,-1))

#TODO is on floor sometimes on a cascade does not help and stuck runes in air
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
	update_sprite()


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
			var need_to_update:Array = []
			need_to_update.append_array(my_chain)
			chain.pop_back()
			chain.append_array(my_chain)
			
			for rune in need_to_update:
				rune.update_chain(at_side, chain)
	
	return my_chain


func detect_body(at_side:int) -> Object:
	var detector: RayCast2D = detectors[at_side]
	detector.force_raycast_update()
	return detector.get_collider()


func is_chainable_rune(body) -> bool:
	return body != null && body.get_class() == my_class && body.color == self.color


func update_chain(at_side:int, new_chain:Array) -> void:
	var my_chain = chains[at_side]
	my_chain.clear()
	my_chain.append_array(new_chain)
	if at_side == SIDE.VERTICAL:
		v_power = my_chain.size()
	elif at_side == SIDE.HORIZONTAL:
		h_power = my_chain.size()
	update_sprite()


func snap_position() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	position = Vector2(snap_x, position.y)


func update_sprite() -> void:
	sprite.frame = min(get_power()-1, max_power-2)


func explode() -> void:
	if get_power() >= max_power:
		sprite.frame = max_power-1
		tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0, fade_time).set_trans(Tween.TRANS_SINE)
		tween.connect("finished", self, "gone")
	else:
		emit_signal("explode", null)
	
	reset_chains()


func get_power() -> float:
	return max(v_power, h_power)


func reset_chains() -> void:
	for chain in chains:
		chain.clear()


func get_class() -> String:
	return my_class


func gone() -> void:
	emit_signal("explode", null)
	queue_free()
