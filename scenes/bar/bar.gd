extends Node2D

@export var bgm : AudioStream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.play_bgm(bgm)
	SoundManager.play_sfx('BarWind')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
