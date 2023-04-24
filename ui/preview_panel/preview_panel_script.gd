extends Control

export (Array, Rune.COLOR) var preview_color_array setget set_preview

onready var first_preview = $PreviewNext/PreviewRunes
onready var second_preview = $PreviewAfterNext/PreviewRunes

#TODO ATTACH THIS DINAMCALY AND ADD TWEENS!!!!
func set_preview(preview_array:Array) -> void:
	if preview_array.size() == 4:
		first_preview.side_preview_color = preview_array[0]
		first_preview.pivot_preview_color = preview_array[1]
		second_preview.side_preview_color = preview_array[2]
		second_preview.pivot_preview_color = preview_array[3]
