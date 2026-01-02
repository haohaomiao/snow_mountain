extends CharacterBody2D

@export var MAXSPEED: float = 300.0
@export var ACCELERATION: float = 600.0

@export var skate_fade_in_seconds: float = 0.15
@export var skate_fade_out_seconds: float = 0.2
@export var skate_muted_volume_db: float = -80.0

var _input_dir: Vector2 = Vector2.ZERO
var _current_dir: Vector2 = Vector2.ZERO
var _current_speed: float = 0.0

var _skate_player: AudioStreamPlayer
var _skate_initial_volume_db: float = 0.0
var _skate_fade_tween: Tween
var _is_skating: bool = false

func _ready() -> void:
	_skate_player = SoundManager.get_node_or_null("SFX/SkiSkate") as AudioStreamPlayer
	if _skate_player == null:
		push_warning("SkiPlayer: SoundManager SFX/SkiSkate not found.")
		return

	_skate_initial_volume_db = _skate_player.volume_db
	_skate_player.volume_db = skate_muted_volume_db
	_skate_player.stop()

func _physics_process(delta: float) -> void:
	_input_dir = Input.get_vector("left", "right", "up", "down")
	if _input_dir == Vector2.ZERO:
		_current_dir = Vector2.ZERO
		_current_speed = 0.0
		velocity = Vector2.ZERO
		_set_skate_sfx_active(false)
		move_and_slide()
		return

	if _current_dir == Vector2.ZERO or not _input_dir.is_equal_approx(_current_dir):
		_current_dir = _input_dir
		_current_speed = 0.0

	_current_speed = minf(MAXSPEED, _current_speed + ACCELERATION * delta)
	velocity = _current_dir * _current_speed
	_set_skate_sfx_active(true)
	move_and_slide()

func _exit_tree() -> void:
	_is_skating = false

	if _skate_fade_tween != null:
		_skate_fade_tween.kill()
		_skate_fade_tween = null

	if _skate_player == null:
		return

	_skate_player.stop()
	_skate_player.volume_db = _skate_initial_volume_db

func _set_skate_sfx_active(active: bool) -> void:
	if _skate_player == null:
		return
	if _is_skating == active:
		return
	_is_skating = active

	if _skate_fade_tween != null:
		_skate_fade_tween.kill()
		_skate_fade_tween = null

	if active:
		if not _skate_player.playing:
			_skate_player.volume_db = skate_muted_volume_db
			_skate_player.stream_paused = false
			_skate_player.play()

		if skate_fade_in_seconds <= 0.0:
			_skate_player.volume_db = _skate_initial_volume_db
			return

		_skate_fade_tween = create_tween()
		_skate_fade_tween.tween_property(_skate_player, "volume_db", _skate_initial_volume_db, skate_fade_in_seconds)
		return

	if not _skate_player.playing:
		_skate_player.volume_db = _skate_initial_volume_db
		return

	if skate_fade_out_seconds <= 0.0:
		_skate_player.stop()
		_skate_player.volume_db = _skate_initial_volume_db
		return

	_skate_fade_tween = create_tween()
	_skate_fade_tween.tween_property(_skate_player, "volume_db", skate_muted_volume_db, skate_fade_out_seconds)
	_skate_fade_tween.tween_callback(func() -> void:
		_skate_player.stop()
		_skate_player.volume_db = _skate_initial_volume_db
	)
