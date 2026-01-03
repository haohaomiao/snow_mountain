extends Node2D
@export_group('bgm')
@export var day_1_2_3_bgm : AudioStream
@export var day_4_bgm : AudioStream
@export var day_5_bgm : AudioStream

@export_group('look')
@export var intro_look : PackedScene
@export var christmas_look : PackedScene
@onready var look_path: NodePath = "VisualObjects/Look"

var bgm : AudioStream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_bgm()
	match_look()
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

func match_look() -> void:
	
	match GameState.day:
		4:
			instantiate_under(look_path,intro_look)
		5:
			instantiate_under(look_path,christmas_look)
		_:
			pass
			
func instantiate_under(path: NodePath, scene: PackedScene) -> Node:
	var parent := get_node(path)
	parent.get_child(0).queue_free()
	var inst := scene.instantiate()
	parent.add_child(inst)
	return inst
