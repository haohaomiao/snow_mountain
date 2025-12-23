# res://globals/sound_manager.gd
extends Node

var _bgm: AudioStreamPlayer
var _sfx: AudioStreamPlayer

# 最小：在这里集中配置（后面再升级成资源配置给音效老师调）
const BGM := {
    "bgm1": "res://assets/bgm1.wav",
    # 以下这些暂时没有
    "bar": "res://audio/bgm/bar.ogg",
    "ski": "res://audio/bgm/ski.ogg",
}

const SFX := {
    # 以下这些暂时没有
    "ui_click": "res://audio/sfx/click.wav",
    "bar_door": "res://audio/sfx/door.wav",
    "fire_crackle": "res://audio/sfx/fire.wav",
}

func _ready() -> void:
    _bgm = AudioStreamPlayer.new()
    _sfx = AudioStreamPlayer.new()
    add_child(_bgm)
    add_child(_sfx)

    EventBus.play_bgm.connect(_on_play_bgm)
    # EventBus.play_sfx.connect(_on_play_sfx)

func _on_play_bgm(id: String) -> void:
    var path: String = BGM.get(id, "")
    if path == "":
        push_warning("Unknown BGM id: %s" % id)
        return
    var stream := load(path) as AudioStream
    if stream == null:
        push_error("Failed to load BGM: %s" % path)
        return
    if _bgm.playing and _bgm.stream == stream:
        return
    _bgm.stream = stream
    _bgm.play()

func _on_play_sfx(id: String) -> void:
    var path: String = SFX.get(id, "")
    if path == "":
        push_warning("Unknown SFX id: %s" % id)
        return
    var stream := load(path) as AudioStream
    if stream == null:
        push_error("Failed to load SFX: %s" % path)
        return
    _sfx.stream = stream
    _sfx.play()
