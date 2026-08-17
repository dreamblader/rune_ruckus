extends Resource
class_name ScoreData

@export var player_name:String = ""
@export var score:float = 0
@export var game_time:String = ""
@export var spells_cast:int = 0
@export var most_used_spell:String = ""

const NAME_KEY = "player_name"
const SCORE_KEY = "score"
const GAME_TIME_KEY = "game_time"
const SPELLS_CAST_KEY = "spells_cast"
const MOST_CAST_KEY = "most_used_spell"


func _init(_player_name: String, _score:float, _game_time:String, _spells_cast:int, _most_used_spell:String) -> void:
	self.player_name = _player_name
	self.score = _score
	self.game_time = _game_time
	self.spells_cast = _spells_cast
	self.most_used_spell = _most_used_spell


static func from_dictionary(dict:Dictionary) -> ScoreData:
	return ScoreData.new(dict[NAME_KEY], dict[SCORE_KEY], dict[GAME_TIME_KEY], dict[SPELLS_CAST_KEY], dict[MOST_CAST_KEY])


func to_dictionary() -> Dictionary:
	return {
		NAME_KEY: player_name,
		SCORE_KEY: score,
		GAME_TIME_KEY: game_time,
		SPELLS_CAST_KEY: spells_cast,
		MOST_CAST_KEY: most_used_spell
	}
