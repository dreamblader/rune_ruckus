extends KinematicBody2D

enum SidePosition {TOP, RIGHT, BOTTOM, LEFT}

onready var timer: Timer = $Timer
onready var collision: CollisionShape2D = $CollisionShape2D
onready var side_rune = $SideRune
onready var pivot_rune= $PivotRune

var side_position: int = SidePosition.TOP
var tick_time: float = 1.0
var tick_move: float
var move: float


func _ready() -> void:
	#pivot_rune.active = true
	#side_rune.active = true
	#side_rune.toggle_border(false)
	timer.wait_time = tick_time


func _input(event: InputEvent) -> void:
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


func _process(delta: float) -> void:
	pass
	#side_rune.position = pivot_rune.position


func move_horizontal(direction:int) -> void:
	move_and_collide(Vector2(move*direction, 0.0))


func rotate_runes(direction:int) -> void:
	var tween = get_tree().create_tween()
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
		SidePosition.LEFT:
			move_collision_to = Vector2(0, 40)
			move_rune_to = Vector2(-80, 0)
		SidePosition.TOP:
			move_collision_to = Vector2(40, 0)
			move_rune_to = Vector2(0, -80)
			
	collision.position = move_collision_to
	tween.tween_property(side_rune, "position", move_rune_to, 0.25).set_trans(Tween.TRANS_QUAD)
	move_and_slide(Vector2())
	print(collision.position + position)
	snap_position()


func move_down() -> void:
	var pivot_collide = move_and_collide(Vector2(0.0, tick_move))
	timer.wait_time = tick_time


func snap_position() -> void:
	position = Vector2(floor(position.x), floor(position.y))
	#print(collision.position + position)


func _on_Timer_timeout() -> void:
	move_down()
