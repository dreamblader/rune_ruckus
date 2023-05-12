extends Node
class_name Menu

export (Array, String) var options
export (Font) var menu_font
export (NodePath) var root_path

var root:Node
var menu_container:VBoxContainer
var selected_index:int = 0
var history_index:int = -1


func _input(event: InputEvent) -> void:
	if !options.empty():
		if event.is_action_pressed("ui_up"):
			selected_index = (selected_index+1) % options.size()
			update_menu_selection()
			add_index_to_history()
		
		if event.is_action_pressed("ui_down"):
			selected_index = selected_index-1 if selected_index > 0 else options.size()-1
			update_menu_selection()
			add_index_to_history()
		
		if event.is_action_pressed("ui_accept"):
			on_option_selected()


func _ready() -> void:
	if root_path.is_empty():
		root = self
	else:
		root = get_node(root_path)
	_render_menu()
	update_menu_selection()
	add_index_to_history()


func update_menu_selection() -> void:
	#implement here the menu visual update
	push_error("MenuException: _update_menu_selection not implemented for "+name) #implement here the menu visual update


func on_option_selected() -> void:
	#implement here the menu option selection
	push_error("MenuException: _on_option_selected not implemented for "+name) 


func _add_option(option:String) -> void:
	options.push(option)
	_add_label(option)


func _render_menu() -> void:
	menu_container = VBoxContainer.new()
	root.add_child(menu_container)
	for option in options:
		_add_label(option) 


func _add_label(option_name:String) -> void:
	var new_option = Label.new()
	new_option.add_font_override("font", menu_font)
	new_option.text = option_name
	menu_container.add_child(new_option)


func get_option_label(index:int) -> Label:
	if index >= 0 && index < menu_container.get_child_count():
		return menu_container.get_child(index) as Label
	else:
		return null


func add_index_to_history() -> void:
	history_index = selected_index
