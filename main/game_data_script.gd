extends Node

const PATH = "user://score.save"
const MAX_BOARD_SIZE = 25
enum GAMEMODE {A, B}
#TODO add psudeo board resource here and create it for real for A and B GameModes

var pseudo_leaderboard_scores = {
	"A": [{
		"A": 100, 
		"B": 100 , 
		"C": 100 , 
		"D": 100, 
		"E": 100, 
		"F": 100, 
		"G":100 , 
		"H": 100, 
		"I":100, 
		"J":100
		}],
	"B": [{
		"A": 100, 
		"B": 100 , 
		"C": 100 , 
		"D": 100, 
		"E": 100, 
		"F": 100, 
		"G":100 , 
		"H": 100, 
		"I":100, 
		"J":100
		}],
	}

var game_data = {
	"spells":{
		"xxx_spells_cast": 0,
		"xyx_spells_cast": 0
	},
	"score":{
		"A":[],
		"B": []
	}
}

var view_board = {
	"A":[],
	"B":[]
}

func _ready() -> void:
	load_leaderboard()


func load_leaderboard() -> void:
	var file = FileAccess.open(PATH, FileAccess.READ)
	
	if file:
		game_data = file.get_var(game_data)
		file.close()
	
	update_view_board("A")
	update_view_board("B")


func save_file() -> void:
	var file = FileAccess.open(PATH, FileAccess.WRITE)
	file.store_var(game_data)
	file.close()


func get_rank(mode: int, score: float) -> int:
	var current_rank = 1
	var current_view_board = view_board[mode]
	while score < current_view_board[current_rank -1]:
		current_rank += 1
	return current_rank


func update_view_board(type:String) -> void:
	var current_game_score_data =  game_data.score[type]
	var current_view_board = view_board[type]
	var current_pseudo_leaderboard = pseudo_leaderboard_scores[type]
	
	if current_game_score_data.size() == 0:
		current_view_board = current_pseudo_leaderboard
	else:
		var data_index = 0
		var pseudo_index = 0
		while current_view_board.size() < MAX_BOARD_SIZE && data_index < current_game_score_data.size() && pseudo_index < current_pseudo_leaderboard.size():
			if current_game_score_data[data_index] > current_pseudo_leaderboard[pseudo_index]:
				current_view_board.append(current_game_score_data[data_index])
				data_index += 1
			else:
				current_view_board.append(current_pseudo_leaderboard[pseudo_index])
				pseudo_index += 1
	
	prints(type, view_board[type])
