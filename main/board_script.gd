extends Node2D
class_name Game

#GLOBALS
var GRAVITY:float = 15
var GRID_SIZE:Vector2 = Vector2(80.0, 80.0)
var GAME_SIZE:Vector2 = Vector2(6.0, 12.0)
var TICK_MOVE: float = GRID_SIZE.y/2
var FADE_TIME: float = 0.35
var COLOR_MULT: int = 6 #increase +1 per extra color (starts at 2 colors)
var CHAIN_MULT: int = 4

var pause: bool = false
var on_wait: bool = false
var continue_chain = false

var unlocked_colors: Array = [Rune.COLOR.RED, Rune.COLOR.YELLOW, Rune.COLOR.BLUE]
var next_runes: Array = []
var color_chain: Array = []
var rng = RandomNumberGenerator.new()

export (PackedScene) var rune_scene

onready var player = $Player

signal emit_orb(at_position)
signal emit_preview_runes(preview_runes)
signal emit_score(value)
signal emit_chain(value)
signal submit_score()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		pause = !pause
		get_tree().paused = pause


func _ready():
	start()


func start():
	rng.randomize()
	generate_runes()
	player.tick_move = TICK_MOVE
	player.move = GRID_SIZE.x
	spawn_player()


func generate_runes() -> void:
	while next_runes.size() < 4:
		var random_color_index = rng.randi_range(0, unlocked_colors.size()-1)
		next_runes.append(unlocked_colors[random_color_index])
	emit_signal("emit_preview_runes", next_runes)


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
			emit_signal("emit_chain", chain_count_start+get_color_chain_score())
			yield(get_tree().create_timer(FADE_TIME+extra_padding_time, false), "timeout")
			solve(chain_count_start+CHAIN_MULT)
			return
	spawn_player()
	color_chain.clear()
	emit_signal("submit_score")


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
				if !color_chain.has(rune.color):
					color_chain.append(rune.color)
				emit_signal("emit_score", 1)
				continue_chain = true


func _on_Player_place_runes(insta_position, pivot_rune, side_rune) -> void:
	put_new_rune(insta_position + pivot_rune.position, pivot_rune)
	put_new_rune(insta_position + side_rune.position, side_rune)
	solve(0)


func put_new_rune(rune_position, old_rune) -> void:
	var new_rune = rune_scene.instance()
	new_rune.add_to_group("Rune")
	new_rune.position = rune_position
	new_rune.gravity = GRAVITY
	new_rune.fade_time = FADE_TIME
	add_child(new_rune)
	new_rune.color = old_rune.color
	new_rune.connect("explode", self, "_on_Rune_explode")


func get_color_chain_score() -> int:
	if color_chain.size() > 1:
		var chain_power = 0
		for i in range(color_chain.size()-1):
			chain_power +=  COLOR_MULT+i
		return chain_power
	else:
		return 0


func _on_Rune_explode(explode_position, explode_color) -> void:
	emit_signal("emit_orb", explode_position, explode_color)
