extends Node

func _ready() -> void:
    SoundManager.ready_for_use.connect(play_bgm)

func play_bgm() -> void:
    SoundManager.play_bgm(preload("res://music/bgm/SnowField_MusicDemo_1221-2.ogg"))


func _on_start_button_pressed() -> void:
    EventBus.go("ski")


func _on_about_button_pressed() -> void:
    $AboutLayer.visible = true

func _on_dim_clicked() -> void:
    $AboutLayer.visible = false
