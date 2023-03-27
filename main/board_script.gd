extends Node2D
class_name Game

#GLOBALS
var GRAVITY:float = 15
var GRID_SIZE:Vector2 = Vector2(80.0, 80.0)
var GAME_SIZE:Vector2 = Vector2(6.0, 12.0)
var TICK_MOVE: float = GRID_SIZE.y/2

onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	$RuneRed.gravity = GRAVITY
	player.tick_move = TICK_MOVE
	player.move = GRID_SIZE.x
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
