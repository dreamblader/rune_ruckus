extends Node2D

export (Texture) var red_rune
export (Texture) var blue_rune
export (Texture) var yellow_rune

onready var side_preview = $SidePreview
onready var pivot_preview = $PivotPreview


func set_side_color(color_index:int) -> void:
	side_preview.texture = get_color_texture(color_index)


func set_pivot_color(color_index:int) -> void:
	pivot_preview.texture = get_color_texture(color_index)


func get_color_texture(color_index:int) -> Texture:
	match color_index:
		Rune.COLOR.RED:
			return red_rune
		Rune.COLOR.YELLOW:
			return yellow_rune
		Rune.COLOR.BLUE:
			return blue_rune
		_:
			return red_rune
