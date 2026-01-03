extends Node2D

var exit_dir := Vector2.from_angle(deg_to_rad(-12.0))
@export var exit_duration := 3.0

@export var EXIT_DISTANCE := 2000.0
@export var single_bgm : AudioStream
@export var double_bgm : AudioStream
@onready var _sky: CanvasItem = $EstablishingShot/Sky
@onready var _sky_alt: CanvasItem = $EstablishingShot/Sky_
@onready var _mountains: CanvasItem = $EstablishingShot/Mountains
@onready var _mountains_alt: CanvasItem = $EstablishingShot/Mountains_
@onready var _snow_track: CanvasItem = $CloseShot/SnowTrack
@onready var _snow_track_alt: CanvasItem = $CloseShot/SnowTrack_
@onready var ski_player: Node2D = $ski_player
@onready var ski_npc: SkiNpc = $ski_npc

var bgm : AudioStream = single_bgm
func _ready() -> void:
	_apply_day_state(GameState.day)
	match_bgm(GameState.day)
	SoundManager.play_bgm(bgm)
	SoundManager.play_sfx('SkiWind')
	$SkiTimer.timeout.connect(_on_ski_timer_timeout)
	EventBus.day_changed.connect(_on_day_changed)

func _on_ski_timer_timeout() -> void:
	print('结束滑雪')
	await _exit_player_offscreen()
	EventBus.go("bar")

func _exit_player_offscreen() -> void:
	# 玩家沿 -dir 冲出屏幕
	var dir := (-exit_dir)

	var target_world := ski_player.global_position + dir * EXIT_DISTANCE
	var duration := maxf(0.0, exit_duration)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(ski_player, "global_position", target_world, duration)
	await tween.finished

func _on_day_changed(cur_day: int) -> void:
	_apply_day_state(cur_day)
	match_bgm(cur_day)
	SoundManager.play_bgm(bgm)

func match_bgm(day: int) -> void:
	match day:
		4:
			bgm = double_bgm
		_:
			bgm = single_bgm

func _apply_day_state(day: int) -> void:
	var is_day4 := day == 4
	_set_variant_visible(_sky, _sky_alt, is_day4)
	_set_variant_visible(_mountains, _mountains_alt, is_day4)
	_set_variant_visible(_snow_track, _snow_track_alt, is_day4)
	if ski_npc != null:
		ski_npc.visible = is_day4
		ski_npc.set_follow_enabled(is_day4)

func _set_variant_visible(normal_node: CanvasItem, variant_node: CanvasItem, use_variant: bool) -> void:
	if normal_node != null:
		normal_node.visible = not use_variant
	if variant_node != null:
		variant_node.visible = use_variant
