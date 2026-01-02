# res://globals/sound_manager.gd
extends Node

@onready var sfx: Node = $SFX
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

signal ready_for_use

func _ready() -> void:
	emit_signal("ready_for_use")
	
func play_sfx(name: String) -> AudioStreamPlayer:
	var player := sfx.get_node(name) as AudioStreamPlayer
	if not player:
		print('未找到音效文件 %s' % name)
		return
	player.play()
	return player
	
func play_bgm(strem: AudioStream) -> void:
	print("play_bgm")
	if bgm_player.stream == strem and bgm_player.playing:
		return
	bgm_player.stream = strem
	bgm_player.play()

#对于静态的互动对象（实例化场景），我们可以用这个函数去进行setup
func setup_sounds(node: Node, sfx: String) -> void:
	var object := node as Button#例如这里是按钮，就可以connect按钮的信号
	if object:
		object.pressed.connect(play_sfx.bind(sfx))
		pass
	pass
