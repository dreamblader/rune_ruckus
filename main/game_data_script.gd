extends Node

const PATH = "user://score.save"
const MAX_BOARD_SIZE = 25
enum GAMEMODE {A, B}

var pseudo_board: Array[ScoreData] = [
	ScoreData.new("Test1", 10000, "", 0, ""),
	ScoreData.new("Test2", 5000, "", 0, ""),
	ScoreData.new("Test3", 2500, "", 0, ""),
	ScoreData.new("Test4", 2000, "", 0, ""),
	ScoreData.new("Test5", 1500, "", 0, ""),
	ScoreData.new("Test6", 1000, "", 0, ""),
	ScoreData.new("Test7", 800, "", 0, ""),
	ScoreData.new("Test8", 700, "", 0, ""),
	ScoreData.new("Test9", 500, "", 0, ""),
	ScoreData.new("Test10", 250, "", 0, "")
]


var pseudo_leaderboard_scores = {
	"A": pseudo_board,
	"B": pseudo_board,
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


func get_rank(mode: String, score: float) -> int:
	var current_rank = 1
	var current_view_board = view_board[mode]
	while current_rank <= current_view_board.size() && score < current_view_board[current_rank -1].score:
		current_rank += 1
	return current_rank


func update_view_board(type:String) -> void:
	var current_game_score_data =  game_data.score[type]
	var current_view_board = view_board[type]
	var current_pseudo_leaderboard: Array[ScoreData] = pseudo_leaderboard_scores[type]
	
	if current_game_score_data.size() == 0:
		current_view_board.clear()
		current_view_board.append_array(current_pseudo_leaderboard)
	else:
		var data_index = 0
		var pseudo_index = 0
		while current_view_board.size() < MAX_BOARD_SIZE && data_index < current_game_score_data.size() && pseudo_index < current_pseudo_leaderboard.size():
			if current_game_score_data[data_index].score > current_pseudo_leaderboard[pseudo_index].score:
				current_view_board.append(current_game_score_data[data_index])
				data_index += 1
			else:
				current_view_board.append(current_pseudo_leaderboard[pseudo_index])
				pseudo_index += 1


func can_save(game_mode:GAMEMODE, score:ScoreData) -> bool:
	var game_mode_key = GameData.GAMEMODE.find_key(game_mode)
	var current_save_board: Array = game_data.score[game_mode_key]
	
	if current_save_board.size() < MAX_BOARD_SIZE:
		return true
	
	var final_score = current_save_board[-1].score
	return score.score >= final_score
