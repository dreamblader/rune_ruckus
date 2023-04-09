extends Node2D
class_name Game

#GLOBALS
var GRAVITY:float = 500
var GRID_SIZE:Vector2 = Vector2(80.0, 80.0)
var GAME_SIZE:Vector2 = Vector2(6.0, 12.0)
var TICK_MOVE: float = GRID_SIZE.y/2

var pause: bool = false
var on_wait: bool = false

var unlocked_colors: Array = [Rune.COLOR.RED, Rune.COLOR.BLUE]
var next_runes: Array = []
var rng = RandomNumberGenerator.new()

export (PackedScene) var red_rune
export (PackedScene) var blue_rune

onready var player = $Player


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pause = !pause
		get_tree().paused = pause


func _ready():
	rng.randomize()
	generate_runes()
	player.tick_move = TICK_MOVE
	player.move = GRID_SIZE.x
	spawn_player()


func generate_runes() -> void:
	while next_runes.size() < 4:
		var random_color_index = rng.randi_range(0, unlocked_colors.size()-1)
		next_runes.append(unlocked_colors[random_color_index])


func spawn_player() -> void:
	player.respawn(next_runes.pop_front(), next_runes.pop_front())
	generate_runes()


func solve() -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		yield(rune, "touch_the_ground")
		#WAIT ALL RUNES TO FALL FIRST BEFORE CHAIN CHECKING
		rune.init_chain_check()
	yield(explode(), "completed")
	print("NEXT----STEP! ==================================================>")
	#ENTIRE CHAIN ALGORITHM GOES HERE (DEPTH-FIRST)
	#AFTER ALL CHAIN ANIMATIONS END CALL RESPAWN
	spawn_player()


func explode() -> void:
	get_tree().call_group("Rune", "explode")
	yield(get_tree(), "idle_frame")


func _on_Player_place_runes(insta_position, pivot_rune, side_rune) -> void:
	var new_rune_from_pivot = get_rune_instance(pivot_rune)
	var new_rune_from_side = get_rune_instance(side_rune)
	new_rune_from_pivot.add_to_group("Rune")
	new_rune_from_side.add_to_group("Rune")
	new_rune_from_pivot.position = insta_position + pivot_rune.position
	new_rune_from_side.position = insta_position + side_rune.position
	new_rune_from_pivot.gravity = GRAVITY
	new_rune_from_side.gravity = GRAVITY
	add_child(new_rune_from_pivot)
	add_child(new_rune_from_side)
	solve()


func get_rune_instance(rune) -> Node:
	match rune.color:
		rune.COLOR.RED:
			return red_rune.instance()
		rune.COLOR.BLUE:
			return blue_rune.instance()
		_:
			return red_rune.instance()
