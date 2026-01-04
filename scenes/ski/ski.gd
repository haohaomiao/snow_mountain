extends Node2D

var exit_dir := Vector2.from_angle(deg_to_rad(-12.0))
@export var exit_duration := 3.0

@export var EXIT_DISTANCE := 2000.0
@export var single_bgm : AudioStream
@export var double_bgm : AudioStream

var bgm : AudioStream = single_bgm
func _ready() -> void:
    match_bgm()
    SoundManager.play_bgm(bgm)
    SoundManager.play_sfx('SkiWind')
    $SkiTimer.timeout.connect(_on_ski_timer_timeout)
    EventBus.day_changed.connect(match_bgm)

func _on_ski_timer_timeout() -> void:
    print('结束滑雪')
    await _exit_player_offscreen()
    EventBus.go("bar")

func _exit_player_offscreen() -> void:
    var player := get_node_or_null("ski_player") as Node2D
    # 玩家沿 -dir 冲出屏幕
    var dir := (-exit_dir)

    var target_world := player.global_position + dir * EXIT_DISTANCE
    var duration := maxf(0.0, exit_duration)

    var tween := create_tween()
    tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
    tween.tween_property(player, "global_position", target_world, duration)
    await tween.finished

func match_bgm() -> void:
    match GameState.day:
        4:
            bgm = double_bgm
        _:
            bgm = single_bgm
    
