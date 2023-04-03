extends KinematicBody2D

enum SidePosition {TOP, RIGHT, BOTTOM, LEFT}

onready var timer: Timer = $Timer
onready var collision: CollisionShape2D = $CollisionShape2D
onready var side_rune = $SideRune
onready var pivot_rune= $PivotRune
onready var areas = $Areas

var rune_size = 80
var tween: SceneTreeTween 
var side_position: int = SidePosition.TOP
var tick_time: float = 1.0
var tick_move: float
var move: float

signal place_runes(insta_position, pivot_rune, side_rune)


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("ui_left"):
			move_horizontal(-1)
			
		if event.is_action_pressed("ui_right"):
			move_horizontal(1)
		
		if event.is_action_pressed("ui_down"):
			move_down()
		
		if event.is_action_pressed("rotate_r"):
			rotate_runes(1)
		
		if event.is_action_pressed("rotate_l"):
			rotate_runes(-1)


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
		prints("Colission:", collide)
		if collide != null:
			wall_bounce()
		snap_position()


func move_down() -> void:
	var snapshot_position_y = position.y
	var pivot_collide = move_and_collide(Vector2(0.0, tick_move))
	if pivot_collide != null:
		position.y = snapshot_position_y
		place_runes()
	timer.wait_time = tick_time


func wall_bounce() -> void:
	#TODO BOUNCE ADD IS NO REPELING SIDE RUNES
	var bounce_add = rune_size/4
	match side_position:
		SidePosition.RIGHT:
			position.x -= bounce_add
		SidePosition.BOTTOM:
			var snap_y = floor(position.y/rune_size) * rune_size
			position.y = snap_y
		SidePosition.LEFT:
			position.x += bounce_add
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
