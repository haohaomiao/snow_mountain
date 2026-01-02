extends Node2D

@export var day_1_2_3_bgm : AudioStream
@export var day_4_bgm : AudioStream
@export var day_5_bgm : AudioStream
var bgm : AudioStream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_bgm()
	SoundManager.play_bgm(bgm)
	SoundManager.play_sfx('BarWind')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func match_bgm() -> void:
	match GameState.day:
		4:
			bgm = day_4_bgm
		5:
			bgm = day_5_bgm
		_:
			bgm = day_1_2_3_bgm
