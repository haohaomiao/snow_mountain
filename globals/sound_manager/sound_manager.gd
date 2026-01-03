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

func setup_ui_sounds(node: Node) -> void:
	var button := node as BaseButton
	if button:
		button.pressed.connect(SoundManager.play_sfx.bind('WindowClick'))
		button.mouse_entered.connect(SoundManager.play_sfx.bind('WindowFocus'))
	
	for child in node.get_children():
		setup_ui_sounds(child)

func stop_all_sfx() -> void:
	for s in sfx.get_children() as Array[AudioStreamPlayer]:
		s.stop()
