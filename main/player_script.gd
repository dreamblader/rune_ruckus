extends KinematicBody2D

enum SidePosition {TOP, RIGHT, BOTTOM, LEFT}
enum InputFlag {LEFT, RIGHT, DOWN}

onready var timer: Timer = $Timer
onready var collision: CollisionShape2D = $CollisionShape2D
onready var side_rune = $SideRune
onready var pivot_rune= $PivotRune
onready var areas = $Areas

var rune_size = 80
var tween: SceneTreeTween 
var side_position: int = SidePosition.TOP
var tick_time: float = 1.0
var input_press_cooldown: float = 0.5
var tick_move: float
var move: float
var input_timer:SceneTreeTimer
var last_input_flag: int
var is_holding:bool = false

signal place_runes(insta_position, pivot_rune, side_rune)


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("ui_left"):
			move_horizontal(-1)
			hold_movement(InputFlag.LEFT)
		elif event.is_action_released("ui_left"):
			kill_holding(InputFlag.LEFT)
			
		if event.is_action_pressed("ui_right"):
			move_horizontal(1)
			hold_movement(InputFlag.RIGHT)
		elif event.is_action_released("ui_right"):
			kill_holding(InputFlag.RIGHT)
		
		if event.is_action_pressed("ui_down"):
			move_down()
			hold_movement(InputFlag.DOWN)
		elif event.is_action_released("ui_down"):
			kill_holding(InputFlag.DOWN)
		
		if event.is_action_pressed("rotate_r"):
			rotate_runes(1)
		
		if event.is_action_pressed("rotate_l"):
			rotate_runes(-1)
		
		if event.is_action_pressed("drop"):
			drop()


func hold_movement(my_flag:int) -> void:
	input_timer = get_tree().create_timer(input_press_cooldown, false)
	input_timer.connect("timeout", self, "hold")
	last_input_flag = my_flag


func kill_holding(my_flag:int) -> void:
	if last_input_flag == my_flag:
		if input_timer != null:
			input_timer.disconnect("timeout", self, "hold")
			input_timer = null
		if is_holding:
			is_holding = false
		last_input_flag = -1


func hold() -> void:
	is_holding = true


func _process(delta: float) -> void:
	if is_holding:
		match(last_input_flag):
			InputFlag.LEFT:
				move_horizontal(-1)
			InputFlag.RIGHT:
				move_horizontal(1)
			InputFlag.DOWN:
				move_down()


func move_horizontal(direction:int) -> void:
	var snapshot_position_x = position.x
	var collision = move_and_collide(Vector2(move*direction, 0.0))
	if collision != null:
		position.x = snapshot_position_x
	snap_position()


func rotate_runes(direction:int) -> void:
	if can_rotate():
		tween = get_tree().create_tween()
		var move_rune_to = Vector2()
		var move_collision_to = Vector2()
		var new_position = (side_position+direction)%SidePosition.size()
		side_position = new_position if new_position >= 0 else SidePosition.size() + new_position
		collision.rotate(direction*PI/2)
		
		match side_position:
			SidePosition.RIGHT:
				move_collision_to = Vector2(80, 40) 
				move_rune_to = Vector2(80, 0)
			SidePosition.BOTTOM:
				move_collision_to = Vector2(40, 80)
				move_rune_to = Vector2(0, 80)
				areas.position = Vector2(0, 80)
			SidePosition.LEFT:
				move_collision_to = Vector2(0, 40)
				move_rune_to = Vector2(-80, 0)
			SidePosition.TOP:
				move_collision_to = Vector2(40, 0)
				move_rune_to = Vector2(0, -80)
				areas.position = Vector2()
				
				
		collision.position = move_collision_to
		tween.tween_property(side_rune, "position", move_rune_to, 0.25).set_trans(Tween.TRANS_QUAD)
		var collide = move_and_collide(Vector2())
		
		if collide != null:
			wall_bounce(collide.collider.position)
		snap_position()


func drop() -> void:
	move_and_collide(Vector2(0.0, 980.0))
	place_runes()


func move_down() -> void:
	var snapshot_position_y = position.y
	var pivot_collide = move_and_collide(Vector2(0.0, tick_move))
	if pivot_collide != null:
		position.y = snapshot_position_y
		place_runes()
	timer.wait_time = tick_time


func wall_bounce(collider_position) -> void:
	match side_position:
		SidePosition.RIGHT:
			position.x = (round(collider_position.x/rune_size)-2) * rune_size
		SidePosition.BOTTOM:
			position.y = (round(collider_position.y/rune_size)-2) * rune_size
		SidePosition.LEFT:
			position.x = (round(collider_position.x/rune_size)+2) * rune_size
		SidePosition.TOP:
			position.y += rune_size


func snap_position() -> void:
	var snap_x = round(position.x/rune_size) * rune_size
	var snap_y = round(position.y/(rune_size*0.5)) * (rune_size*0.5)
	position = Vector2(snap_x, snap_y)


func _on_Timer_timeout() -> void:
	move_down()


func place_runes() -> void:
	if visible && (tween == null || !tween.is_running()):
		snap_position()
		timer.stop()
		collision.disabled = true
		visible = false
		emit_signal("place_runes", position, pivot_rune, side_rune)


func respawn(pivot_rune_color: int, side_rune_color: int) -> void:
	kill_holding(last_input_flag)
	visible = true
	position = Vector2(160,-40)
	reset_rotation()
	pivot_rune.color = pivot_rune_color
	side_rune.color = side_rune_color
	collision.disabled = false
	timer.start(tick_time)


func reset_rotation() -> void:
	side_position = SidePosition.TOP
	areas.position = Vector2()
	collision.rotation = 0
	collision.position = Vector2(40, 0)
	side_rune.position = Vector2(0, -80)


func can_rotate() -> bool:
	var left_area = $Areas/L_Area
	var rigth_area = $Areas/R_Area
	var is_vertical = side_position == SidePosition.BOTTOM || side_position == SidePosition.TOP
	return !(is_vertical && !left_area.get_overlapping_bodies().empty()  && !rigth_area.get_overlapping_bodies().empty())
