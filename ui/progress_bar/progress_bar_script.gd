extends Control

export (StreamTexture) var red_symbol
export (StreamTexture) var blue_symbol
export (StreamTexture) var yellow_symbol
export (Rune.COLOR) var my_color
export (float) var fill_time = 0.35
export (float) var glow_time = 0.15

onready var symbol = $Label
onready var bar = $ProgressBar

var points:float

signal bar_complete(color)

func _ready() -> void:
	colorize()
	points = bar.value


func colorize() -> void:
	match my_color:
		Rune.COLOR.RED:
			apply_color(red_symbol, Color(1.0, 0.19 , 0.0))
		Rune.COLOR.BLUE:
			apply_color(blue_symbol, Color(0.0, 0.19 , 1.0))
		Rune.COLOR.YELLOW:
			apply_color(yellow_symbol, Color(1.0, 1.0 , 0.0))


func apply_color(new_symbol:StreamTexture, tint:Color) -> void:
	symbol.texture = new_symbol
	bar.tint_progress = tint


func add_points(value:int) -> void:
	points += value
	fill_bar()


func fill_bar() -> void:
	var tween = create_tween()
	tween.tween_property(bar, "value", min(points, bar.max_value), fill_time)
	tween.set_trans(Tween.TRANS_SINE)
	tween.connect("finished", self, "check_complete")


func check_complete() -> void:
	if points >= bar.max_value:
		points -= bar.max_value
		create_tween().tween_property(symbol, "modulate", get_glow_color(), glow_time).set_trans(Tween.TRANS_LINEAR).connect("finished", self, "reset_glow")
		emit_signal("bar_complete", my_color)
		fill_bar()


func reset_glow() -> void:
	create_tween().tween_property(symbol, "modulate", Color(1.0, 1.0, 1.0), glow_time).set_trans(Tween.TRANS_LINEAR)


func get_glow_color() -> Color:
		match my_color:
			Rune.COLOR.RED:
				return Color(3.0, 1.0 , 1.0)
			Rune.COLOR.BLUE:
				return Color(1.0, 1.0 , 3.0)
			Rune.COLOR.YELLOW:
				return Color(3.0, 3.0 , 1.0)
			_:
				return Color(1.0, 1.0, 1.0)
