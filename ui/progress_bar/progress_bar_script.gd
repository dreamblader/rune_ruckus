extends Control

export (StreamTexture) var red_symbol
export (StreamTexture) var blue_symbol
export (StreamTexture) var yellow_symbol
export (StreamTexture) var green_symbol
export (StreamTexture) var purple_symbol
export (StreamTexture) var orange_symbol
export (Rune.COLOR) var my_color
export (float) var fill_time = 0.35
export (float) var glow_time = 0.15

onready var symbol = $Label
onready var bar = $ProgressBar

var points:float

signal bar_complete()

func _ready() -> void:
	colorize()
	points = bar.value


func colorize() -> void:
	match my_color:
		Rune.COLOR.RED:
			apply_color(red_symbol, Color(1.0, 0.0 , 0.0))
		Rune.COLOR.BLUE:
			apply_color(blue_symbol, Color(0.0, 0.0 , 1.0))
		Rune.COLOR.YELLOW:
			apply_color(yellow_symbol, Color(1.0, 1.0 , 0.0))
		Rune.COLOR.GREEN:
			apply_color(green_symbol, Color(0.0, 1.0 , 0.0))
		Rune.COLOR.PURPLE:
			apply_color(purple_symbol, Color(1.0, 0.0 , 1.0))
		Rune.COLOR.ORANGE:
			apply_color(orange_symbol, Color(1.0, 0.33 , 0.0))


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
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(symbol, "modulate", get_glow_color(), glow_time)
		tween.connect("finished", self, "reset_glow")
		emit_signal("bar_complete")
		fill_bar()


func reset_glow() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(symbol, "modulate", Color(1.0, 1.0, 1.0), glow_time)
	


func appear() -> void:
	var animation_time:float = 0.5
	bar.rect_size.y = 0
	symbol.modulate.a = 0
	visible = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(bar, "rect_size:y", 200, animation_time)
	tween.tween_property(symbol, "modulate:a", 1, animation_time)


func get_glow_color() -> Color:
		match my_color:
			Rune.COLOR.RED:
				return Color(3.0, 1.0 , 1.0)
			Rune.COLOR.BLUE:
				return Color(1.0, 1.0 , 3.0)
			Rune.COLOR.YELLOW:
				return Color(3.0, 3.0 , 1.0)
			Rune.COLOR.GREEN:
				return Color(1.0, 3.0, 1.0)
			Rune.COLOR.PURPLE:
				return Color(3.0, 1.0 , 3.0)
			Rune.COLOR.ORANGE:
				return Color(3.0, 2.33 , 1.0)
			_:
				return Color(1.0, 1.0, 1.0)
