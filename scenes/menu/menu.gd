extends Node
@export var bgm : AudioStream
func _ready() -> void:
    SoundManager.setup_ui_sounds(self)
    play_bgm()

func play_bgm() -> void:
    print('背景音乐')
    SoundManager.play_bgm(bgm)

func _on_start_button_pressed() -> void:
    EventBus.go("ski")

func _on_about_button_pressed() -> void:
    $AboutLayer.visible = true

func _on_dim_clicked() -> void:
    $AboutLayer.visible = false
    
