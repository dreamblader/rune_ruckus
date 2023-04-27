extends Control

export (Array, Rune.COLOR) var preview_color_array setget set_preview
export (PackedScene) var preview_rune

onready var first_preview_panel = $PreviewNext
onready var second_preview_panel = $PreviewAfterNext


var first_preview_positions = [Vector2(109,80), Vector2(40,50), Vector2(-98,-10)]
var second_preview_positions = [Vector2(101,70), Vector2(32,40), Vector2(-37, 10)]
var scales = [Vector2(0.5, 0.5), Vector2(1.0, 1.0), Vector2(1.5, 1.5), Vector2(2.0, 2.0)]
var animation_time = 0.35
var first_preview
var second_preview


func set_preview(preview_array:Array) -> void:
	if preview_array.size() == 4:
		var next_first_preview = attach_preview(preview_array[0], preview_array[1], true)
		var next_second_preview = attach_preview(preview_array[2], preview_array[3], false)
		
		if first_preview != null && second_preview != null:
			var tween:SceneTreeTween = create_tween()
			tween.set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(next_first_preview, "position", first_preview_positions[1], animation_time)
			tween.parallel().tween_property(next_first_preview, "scale", scales[2], animation_time)
			tween.parallel().tween_property(first_preview, "position", first_preview_positions[2], animation_time)
			tween.parallel().tween_property(first_preview, "scale", scales[3], animation_time)
			tween.parallel().tween_property(next_second_preview, "position", second_preview_positions[1], animation_time)
			tween.parallel().tween_property(next_second_preview, "scale", scales[1], animation_time)
			tween.parallel().tween_property(second_preview, "position", second_preview_positions[2], animation_time)
			tween.parallel().tween_property(second_preview, "scale", scales[2], animation_time)
			tween.tween_callback(self, "_on_preview_transition_end", [next_first_preview, next_second_preview])
		else:
			first_preview = next_first_preview
			first_preview.position = first_preview_positions[1]
			first_preview.scale = scales[2]
			second_preview = next_second_preview
			second_preview.position = second_preview_positions[1]
			second_preview.scale = scales[1]


func attach_preview(preview_pivot_color:int, preview_side_color:int, first:bool) -> Node:
	var temp_preview = preview_rune.instance()
	if first:
		temp_preview.position = first_preview_positions[0]
		temp_preview.scale = scales[1]
		first_preview_panel.add_child(temp_preview)
	else:
		temp_preview.position = second_preview_positions[0]
		temp_preview.scale = scales[0]
		second_preview_panel.add_child(temp_preview)
	
	temp_preview.set_side_color(preview_side_color)
	temp_preview.set_pivot_color(preview_pivot_color)
	return temp_preview


func _on_preview_transition_end(next_first:Node, next_second:Node) -> void:
	first_preview.queue_free()
	second_preview.queue_free()
	first_preview = next_first
	second_preview = next_second
