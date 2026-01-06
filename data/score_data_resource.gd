extends Resource

class_name ScoreData

@export var player_name:String = ""
@export var score:int = 0
@export var game_time:int = 0
@export var spells_cast:int = 0

const NAME_KEY = "name"
const SCORE_KEY = "score"
const GAME_TIME_KEY = "time"
const SPELLS_CAST_KEY = "spells_cast"


func _init(_player_name: String, _score:int, _game_time:int, _spells_cast:int) -> void:
	self.player_name = _player_name
	self.score = _score
	self.game_time = _game_time
	self.spells_cast = _spells_cast


func to_dictionary() -> Dictionary:
	return {
		NAME_KEY: player_name,
		SCORE_KEY: score,
		GAME_TIME_KEY: game_time,
		SPELLS_CAST_KEY: spells_cast
	}
