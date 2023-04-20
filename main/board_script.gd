extends Node2D
class_name Game

#GLOBALS
var GRAVITY:float = 15
var GRID_SIZE:Vector2 = Vector2(80.0, 80.0)
var GAME_SIZE:Vector2 = Vector2(6.0, 12.0)
var TICK_MOVE: float = GRID_SIZE.y/2
var FADE_TIME: float = 0.35

var pause: bool = false
var on_wait: bool = false
var continue_chain = false

var unlocked_colors: Array = [Rune.COLOR.RED, Rune.COLOR.YELLOW, Rune.COLOR.BLUE]
var next_runes: Array = []
var rng = RandomNumberGenerator.new()

export (PackedScene) var red_rune
export (PackedScene) var blue_rune
export (PackedScene) var yellow_rune

onready var player = $Player

signal emit_orb(at_position)


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


func solve(chain_count_start:int) -> void:
	var extra_padding_time: float = 0.1
	var runes = get_tree().get_nodes_in_group("Rune")
	if !runes.empty():
		yield(wait_runes_touch_the_ground(runes), "completed")
		check_runes(runes)
		wait_runes_explode(runes)
		if continue_chain:
			yield(get_tree().create_timer(FADE_TIME+extra_padding_time, false), "timeout")
			solve(chain_count_start+1)
			return
	spawn_player()


func wait_runes_touch_the_ground(runes) -> void:
	for rune in runes:
		if rune != null && rune.is_floating:
			yield(rune, "touch_the_ground")
	yield(get_tree(), "idle_frame")


func check_runes(runes) -> void:
	for rune in runes:
		if rune != null:
			rune.init_chain_check()


func wait_runes_explode(runes) -> void:
	continue_chain = false
	for rune in runes:
		if rune != null:
			rune.explode()
			if rune.tween != null:
				continue_chain = true


func _on_Player_place_runes(insta_position, pivot_rune, side_rune) -> void:
	var new_rune_from_pivot = get_rune_instance(pivot_rune)
	var new_rune_from_side = get_rune_instance(side_rune)
	put_new_rune(insta_position + pivot_rune.position, new_rune_from_pivot)
	put_new_rune(insta_position + side_rune.position, new_rune_from_side)
	solve(1)


func put_new_rune(rune_position, new_rune) -> void:
	new_rune.add_to_group("Rune")
	new_rune.position = rune_position
	new_rune.gravity = GRAVITY
	new_rune.fade_time = FADE_TIME
	add_child(new_rune)


func get_rune_instance(rune) -> Node:
	match rune.color:
		rune.COLOR.RED:
			return red_rune.instance()
		rune.COLOR.YELLOW:
			return yellow_rune.instance()
		rune.COLOR.BLUE:
			return blue_rune.instance()
		_:
			return red_rune.instance()
