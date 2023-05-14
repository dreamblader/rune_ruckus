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
var LEVEL: int = 1

var pause: bool = false
var is_over:bool = false
var on_wait: bool = false
var continue_chain = false

var unlocked_colors: Array = [Rune.COLOR.RED, Rune.COLOR.YELLOW, Rune.COLOR.BLUE]
var locked_colors: Array = [Rune.COLOR.GREEN, Rune.COLOR.PURPLE, Rune.COLOR.ORANGE]
var next_runes: Array = []
var color_chain: Array = []
var rng = RandomNumberGenerator.new()

var death_tween:SceneTreeTween
var death_final_position = Vector2(280, 400)
var death_final_scale = Vector2(4, 4)

export (PackedScene) var rune_scene

onready var player = $Player
onready var death_tile = $DeathTile
onready var death = $Death
onready var death_label = $UDiedLabel/MovingLabel
onready var pause_label = $PauseLabel/MovingLabel

signal emit_orb(at_position)
signal emit_preview_runes(preview_runes)
signal emit_score(value)
signal emit_chain(value)
signal submit_score()
signal game_over(menu_flag)


func _input(event: InputEvent) -> void:
	if is_over && event.is_action_pressed("ui_accept"):
		skip_death_animation()
	elif death_tween == null && event.is_action_pressed("ui_accept"):
		pause()


func _ready():
	start()


func start():
	rng.randomize()
	generate_runes()
	player.tick_move = TICK_MOVE
	player.move = GRID_SIZE.x
	spawn_player()


func pause():
	pause = !pause
	get_tree().paused = pause
	toggle_runes_mask(pause)
	if pause:
		pause_label.appear()
	else:
		pause_label.disappear()


func toggle_runes_mask(flag:bool) -> void:
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		if flag:
			rune.mask_rune(rng.randi_range(0, 8))
		else:
			rune.unmask_rune()


func generate_runes() -> void:
	while next_runes.size() < 4:
		var random_color_index = rng.randi_range(0, unlocked_colors.size()-1)
		next_runes.append(unlocked_colors[random_color_index])
	emit_signal("emit_preview_runes", next_runes)


func spawn_player() -> void:
	if death_tile.did_u_died():
		start_game_over()
	else:
		player.respawn(next_runes.pop_front(), next_runes.pop_front())
		generate_runes()


func start_game_over() -> void:
	emit_signal("game_over", false)
	next_runes.clear()
	awake_death_icon()
	LEVEL = 1
	var runes = get_tree().get_nodes_in_group("Rune")
	for rune in runes:
		rune.end()


func awake_death_icon() -> void:
	death_tween = get_tree().create_tween()
	var death_animation_time = 3.0
	var death_animation_delay = 2.0
	death_tile.visible = false
	death.visible = true
	death_tween.set_trans(Tween.TRANS_SINE)
	death_tween.set_ease(Tween.EASE_OUT)
	death_tween.tween_callback(self, "set_is_over", [true]).set_delay(death_animation_delay)
	death_tween.parallel().tween_property(death, "position", death_final_position, death_animation_time).set_delay(death_animation_delay)
	death_tween.parallel().tween_property(death, "scale", death_final_scale, death_animation_time).set_delay(death_animation_delay) 
	death_tween.tween_callback(death_label, "appear")
	death_tween.tween_callback(self, "emit_signal", ["game_over", true]).set_delay(0.5)


func set_is_over(flag:bool) -> void:
	is_over = flag


func skip_death_animation() -> void:
	if death_tween != null:
		death_tween.kill()
		death_tween = null
		death_tile.visible = false
		death.visible = true
		death.position = death_final_position
		death.scale = death_final_scale
		death_label.force_appear()
		emit_signal("game_over", true)


func solve(chain_count_start:int) -> void:
	var extra_padding_time: float = 0.1
	var runes = get_tree().get_nodes_in_group("Rune")
	if !runes.empty():
		yield(wait_runes_touch_the_ground(runes), "completed")
		add_pitch(runes, chain_count_start)
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


func add_pitch(runes, chain_number) -> void:
	var chain_pitch = 0
	if chain_number > 1:
		chain_pitch = floor(chain_number-1/CHAIN_MULT)/10
	for rune in runes:
		rune.set_pitch(chain_pitch)


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


func unlock_color(color_index:int) -> bool:
	var locked_index = locked_colors.find(color_index)
	if locked_index >= 0:
		locked_colors.remove(color_index)
		unlocked_colors.append(color_index)
		return true
	else:
		return false


func _on_Rune_explode(explode_position, explode_color) -> void:
	emit_signal("emit_orb", explode_position, explode_color)
