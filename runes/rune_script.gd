extends CharacterBody2D
class_name Rune

enum COLOR { RED, YELLOW, BLUE, GREEN , PURPLE, ORANGE, NONE, SPECIAL}
enum SPECIALS { PYG, ROY, GOB, BOY}
enum SIDE {VERTICAL, HORIZONTAL}

@export var red_rune : SpriteFrames
@export  var yellow_rune : SpriteFrames
@export var blue_rune : SpriteFrames
@export var green_rune : SpriteFrames
@export var purple_rune : SpriteFrames
@export var orange_rune : SpriteFrames
@export var none_rune : SpriteFrames
@export var pyg_rune : SpriteFrames
@export var roy_rune : SpriteFrames
@export var gob_rune : SpriteFrames
@export var boy_rune : SpriteFrames

@export var color : COLOR = COLOR.RED: set = set_color
var special_type : int = -1

var MAX_POWER_CONST = 4
var chains: Array = [[],[]]

var fade_time:float
var gravity: float
var column_pos: float
var is_floating:bool = true
var does_exist:bool = true
var chain_pitch:float = 1.0

var group: Dictionary
var visited: bool = false
var v_power:int = 1
var h_power:int = 1
var power: int = 1
var max_power:int = 4

var tween:Tween
var update_tween:Tween

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detectors: Array[RayCast2D] = [ $DetectUp, $DetectRigth ]
@onready var explode_sound: AudioStreamPlayer = $ExplodeSound
@onready var drop_sound: AudioStreamPlayer = $DropSound

var start_time

signal exploded(rune)
signal touch_the_ground
signal updated


func _ready() -> void:
	var snap_size: float = 80.0
	var snap_x = round(position.x/snap_size) * snap_size
	sprite.frame = 0
	column_pos = snap_x
	set_color(color)
	reset_chains()


func _physics_process(delta: float) -> void:
	if does_exist && is_floating:
		var collision = move_and_collide(Vector2(0, gravity))
		position.x = column_pos
		if collision != null:
			collision_check(collision.get_collider())


func _process(_delta: float) -> void:
	if does_exist && !is_floating:
		emit_signal("touch_the_ground")


func switch_color(color_value:int, special_id: int = -1) -> void:
	update_tween = get_tree().create_tween()
	#change_sound.play()
	update_tween.set_trans(Tween.TRANS_SINE)
	update_tween.tween_property(self, "modulate", Color(0,0,0), fade_time/2)
	update_tween.tween_property(self, "modulate", Color(1,1,1), fade_time/2)
	
	if color_value != COLOR.SPECIAL:
		update_tween.tween_callback(Callable(self, "set_color").bind(color_value))
	else:
		update_tween.tween_callback(Callable(self, "set_special").bind(special_id))


func set_color(color_value: Rune.COLOR) -> void:
	if !self.is_node_ready():
		return
	
	color = color_value
	match color_value:
		COLOR.RED:
			sprite.frames = red_rune
		COLOR.YELLOW:
			sprite.frames = yellow_rune
		COLOR.BLUE:
			sprite.frames = blue_rune
		COLOR.GREEN:
			sprite.frames = green_rune
		COLOR.PURPLE:
			sprite.frames = purple_rune
		COLOR.ORANGE:
			sprite.frames = orange_rune
		COLOR.SPECIAL:
			pass
		_:
			push_error("INCORRECT SET COLOR EXCEPTION @ Rune")
	finish_update()


func set_special(special_id: int) -> void:
	if special_id < 0:
		special_id = RandomNumberGenerator.new().randi_range(0, SPECIALS.size())
	color = COLOR.SPECIAL
	special_type = special_id
	match special_id:
		SPECIALS.PYG:
			sprite.frames = pyg_rune
		SPECIALS.ROY:
			sprite.frames = roy_rune
		SPECIALS.GOB:
			sprite.frames = gob_rune
		SPECIALS.BOY:
			sprite.frames = boy_rune
		_:
			push_error("INCORRECT SET SPECIAL COLOR ID EXCEPTION @ Rune")
	finish_update()


func finish_update() -> void:
	if update_tween != null:
		update_tween = null
		emit_signal("updated")


func collision_check(collider:Object) -> void:
	if collider is Rune && collider.does_exist:
		is_floating = collider.is_floating
	elif collider.get_class() == "StaticBody2D":
		is_floating = false
	
	if !is_floating:
		drop_sound.play()


func init_chain_check(mode: int) -> void:
	for side in SIDE.values():
		if mode == 0:
			check_chain_A(side, self.group, color)
		else:
			check_chain_B(side, [self])
	self.visited = true
	v_power = chains[SIDE.VERTICAL].size()
	h_power = chains[SIDE.HORIZONTAL].size()
	update_power()


func update_power() -> void:
	power = group.size()
	update_sprite()


func check_chain_A(at_side:int, chain:Dictionary, color_chain: COLOR) -> void:
	if chain != self.group:
		chain.merge(self.group)
		for rune_name in group:
			var rune = group[rune_name]
			rune.group = chain
			rune.update_power()
	
	if visited:
		return
	
	var collider = detect_body(at_side)

	if !is_rune(collider):
		return

	var next_rune = collider as Rune
	var color_of_chain = color_chain if color_chain != COLOR.SPECIAL else next_rune.color
	if is_chainable_rune_A(collider, color_of_chain):
		self.group[next_rune.name] = next_rune
		for side in SIDE.values():
			next_rune.check_chain_A(side, self.group, color_of_chain)
		next_rune.visited = true


func check_chain_B(at_side:int, chain:Array) -> Array:
	var my_chain: Array = self.chains[at_side]
	if my_chain.is_empty():
		my_chain.append_array(chain) 
		var collider = detect_body(at_side)
		if is_chainable_rune_B(collider):
			var next_rune = collider as Rune
			my_chain.append(next_rune)
			var result = next_rune.check_chain_B(at_side, my_chain)
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


func is_chainable_rune_A(rune, color) -> bool:
	return (rune.color == color || rune.color == COLOR.SPECIAL)


func is_chainable_rune_B(body) -> bool:
	return is_rune(body) && (body.color == self.color || chain_has_specials(body))


func chain_has_specials(body) -> bool:
	return self.color == COLOR.SPECIAL || body.color == COLOR.SPECIAL


func is_rune(body) -> bool:
	return body != null && body is Rune


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


func mask_rune(mask_index:int) -> void:
	if get_power() < max_power:
		sprite.frames = none_rune
		sprite.frame = mask_index


func unmask_rune() -> void:
	if color == COLOR.SPECIAL:
		set_special(special_type)
	else:
		set_color(color)
	update_sprite()


func explode() -> void:
	if get_power() >= max_power:
		does_exist = false
		gravity_call()
		sprite.frame = max_power-1
		tween = get_tree().create_tween()
		explode_sound.play()
		tween.tween_property(self, "modulate:a", 0, fade_time).set_trans(Tween.TRANS_SINE)
		tween.connect("finished", Callable(self, "gone"))
	else:
		max_power = MAX_POWER_CONST
	reset_chains()


func gravity_call() -> void:
	is_floating = true
	var possible_rune = detect_body(0)
	if is_rune(possible_rune):
		possible_rune.gravity_call()


func get_power() -> float:
	return max(v_power, h_power, power)


func reset_chains() -> void:
	group = {self.name: self}
	visited = false
	for chain in chains:
		chain.clear()


#func get_class() -> String:
#	return my_class


func set_pitch(pitch_add:float) -> void:
	explode_sound.pitch_scale = min(1+pitch_add, 1.5)


func end() -> void:
	sprite.frame = 2


func gone() -> void:
	emit_signal("exploded", position, color)
	queue_free()


static func colorComparison(rune_a, rune_b):
	return rune_a.color < rune_b.color
