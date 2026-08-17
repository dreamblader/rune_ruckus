extends Node

const PATH = "user://score.save"
const MAX_BOARD_SIZE = 30
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
		game_data = file.get_var()
		file.close()
	else:
		printerr("Failed to open save file")
	
	update_view_board("A")
	update_view_board("B")


func add_player_score(mode:GAMEMODE, score:ScoreData) -> void:
	var mode_key = GAMEMODE.find_key(mode)
	var current_board:Array = game_data["score"][mode_key]
	current_board.append(score.to_dictionary())
	current_board.sort_custom(sort_score_descending)
	save_file()
	update_view_board(mode_key)


func sort_score_descending(a,b) -> bool:
	return a.score > b.score


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
	#FIXME This looks like is not working properly
	var current_game_score_data =  game_data.score[type]
	var current_view_board = view_board[type]
	var current_pseudo_leaderboard: Array[ScoreData] = pseudo_leaderboard_scores[type]
	
	if current_game_score_data.size() == 0:
		current_view_board.clear()
		current_view_board.append_array(current_pseudo_leaderboard)
	else:
		var data_index = 0
		var pseudo_index = 0
		
		while current_view_board.size() < MAX_BOARD_SIZE:
			var player_score_data = current_game_score_data[data_index] if data_index < current_game_score_data.size() else null
			var pseudo_score_data = current_pseudo_leaderboard[pseudo_index] if pseudo_index < current_pseudo_leaderboard.size() else null
			
			if player_score_data == null && pseudo_score_data == null:
				break
			
			if pseudo_score_data == null || player_score_data.score > pseudo_score_data.score:
				current_view_board.append(ScoreData.from_dictionary(player_score_data))
				prints("ADDED PLAYER:", player_score_data.player_name, player_score_data.score)
				data_index += 1
			else:
				current_view_board.append(pseudo_score_data)
				prints("ADDED PSEUDO:", pseudo_score_data.player_name, pseudo_score_data.score)
				pseudo_index += 1


func can_save(game_mode:GAMEMODE, score:ScoreData) -> bool:
	var game_mode_key = GameData.GAMEMODE.find_key(game_mode)
	var current_save_board: Array = game_data.score[game_mode_key]
	
	if current_save_board.size() < MAX_BOARD_SIZE:
		return true
	
	var final_score = current_save_board[-1].score
	return score.score >= final_score
