extends CharacterBody2D

@export var MAXSPEED: float = 300.0
@export var ACCELERATION: float = 600.0
@export var turn_reset_dot_threshold: float = 0.0

@export var skate_fade_in_seconds: float = 0.15
@export var skate_fade_out_seconds: float = 0.2
@export var skate_muted_volume_db: float = -80.0

var _input_dir: Vector2 = Vector2.ZERO
var _current_dir: Vector2 = Vector2.ZERO
var _current_speed: float = 0.0

var _skate_requester: String = ""
var _is_skating: bool = false

func _ready() -> void:
	_skate_requester = "ski_player_%s" % str(get_instance_id())

func _physics_process(delta: float) -> void:
	_input_dir = Input.get_vector("left", "right", "up", "down")
	if _input_dir == Vector2.ZERO:
		_current_dir = Vector2.ZERO
		_current_speed = 0.0
		velocity = Vector2.ZERO
		_set_skate_sfx_active(false)
		move_and_slide()
		return

	if _current_dir == Vector2.ZERO:
		_current_dir = _input_dir
		_current_speed = 0.0
	else:
		var dot := _current_dir.dot(_input_dir)
		if dot < turn_reset_dot_threshold:
			_current_speed = 0.0
		_current_dir = _input_dir

	_current_speed = minf(MAXSPEED, _current_speed + ACCELERATION * delta)
	velocity = _current_dir * _current_speed
	_set_skate_sfx_active(true)
	move_and_slide()

func _exit_tree() -> void:
	_set_skate_sfx_active(false)

func _set_skate_sfx_active(active: bool) -> void:
	if _is_skating == active:
		return
	_is_skating = active
	SoundManager.request_loop_sfx("SkiSkate", _skate_requester, active, skate_fade_in_seconds, skate_fade_out_seconds, skate_muted_volume_db)
