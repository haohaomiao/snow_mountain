extends CharacterBody2D


const SPEED = 50.0

var last_direction: Vector2 = Vector2.DOWN

@export var footstep_fade_in_seconds: float = 0
@export var footstep_fade_out_seconds: float = 0.2
@export var footstep_muted_volume_db: float = -80.0

var _footstep_player: AudioStreamPlayer
var _footstep_initial_volume_db: float = 0.0
var _footstep_fade_tween: Tween
var _is_walking: bool = false

func _ready() -> void:
	_footstep_player = SoundManager.get_node_or_null("SFX/BarFootstep") as AudioStreamPlayer
	if _footstep_player == null:
		push_warning("BarPlayer: SoundManager SFX/BarFootstep not found.")
		return

	_footstep_initial_volume_db = _footstep_player.volume_db
	_footstep_player.volume_db = footstep_muted_volume_db
	_footstep_player.stop()

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	_set_footstep_sfx_active(input_direction != Vector2.ZERO)
	if input_direction != Vector2.ZERO:
		last_direction = input_direction
	velocity = input_direction * SPEED
	move_and_slide()
	_update_animation(input_direction)

func _exit_tree() -> void:
	_is_walking = false

	if _footstep_fade_tween != null:
		_footstep_fade_tween.kill()
		_footstep_fade_tween = null

	if _footstep_player == null:
		return

	_footstep_player.stop()
	_footstep_player.volume_db = _footstep_initial_volume_db

func _set_footstep_sfx_active(active: bool) -> void:
	if _footstep_player == null:
		return
	if _is_walking == active:
		return
	_is_walking = active

	if _footstep_fade_tween != null:
		_footstep_fade_tween.kill()
		_footstep_fade_tween = null

	if active:
		if not _footstep_player.playing:
			_footstep_player.volume_db = footstep_muted_volume_db
			_footstep_player.stream_paused = false
			_footstep_player.play()

		if footstep_fade_in_seconds <= 0.0:
			_footstep_player.volume_db = _footstep_initial_volume_db
			return

		_footstep_fade_tween = create_tween()
		_footstep_fade_tween.tween_property(_footstep_player, "volume_db", _footstep_initial_volume_db, footstep_fade_in_seconds)
		return

	if not _footstep_player.playing:
		_footstep_player.volume_db = _footstep_initial_volume_db
		return

	if footstep_fade_out_seconds <= 0.0:
		_footstep_player.stop()
		_footstep_player.volume_db = _footstep_initial_volume_db
		return

	_footstep_fade_tween = create_tween()
	_footstep_fade_tween.tween_property(_footstep_player, "volume_db", footstep_muted_volume_db, footstep_fade_out_seconds)
	_footstep_fade_tween.tween_callback(func() -> void:
		_footstep_player.stop()
		_footstep_player.volume_db = _footstep_initial_volume_db
	)

func _update_animation(input_direction: Vector2) -> void:
	var motion := "down"
	if last_direction.x != 0:
		motion = "left" if last_direction.x < 0 else "right"
	elif last_direction.y != 0:
		motion = "up" if last_direction.y < 0 else "down"

	var suffix := "_walk" if input_direction != Vector2.ZERO else "_default"
	$AnimatedSprite2D.animation = motion + suffix
