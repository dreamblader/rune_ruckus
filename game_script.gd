extends Control

export (PackedScene) var orb_scene

onready var data = $Content/RightContainer/DataContent
onready var board = $Content/MidContainer/Control/ViewportContainer/Viewport/Board
onready var left_panel = $Content/LeftPadding

var orb_travel_time:float = 0.5

var score:int = 0
var high_score:int = 10000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#TODO GET HIGHSCORE DATA SET SCORE TO 0
	pass # Replace with function body.


func get_color_position(to_color: int) -> Vector2:
	match to_color:
		Rune.COLOR.RED:
			return Vector2()
		_:
			return Vector2()


func _on_Board_emit_orb(at_position, to_color) -> void:
	var tween = create_tween()
	var offset = Vector2(40, 100) + Vector2(left_panel.rect_size.x, 0)
	var go_to = data.get_bar_position(to_color) + Vector2(60, 60)
	var orb = orb_scene.instance()
	orb.position = at_position + offset
	orb.color = to_color
	add_child(orb)
	tween.tween_property(orb, "position", go_to, orb_travel_time)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_callback(self, "orb_reached_goal", [orb, to_color])


func orb_reached_goal(orb, color_index:int) -> void:
	var tween = create_tween()
	data.color_up(1, color_index)
	orb.queue_free()


func _on_Board_emit_score(value) -> void:
	pass # Replace with function body.


func _on_Board_emit_chain(value) -> void:
	pass # Replace with function body.
