extends CharacterBody2D
class_name SkiNpc

@export var follow_enabled: bool = false
@export var follow_target_path: NodePath = NodePath("../ski_player")
@export var follow_offset: Vector2 = Vector2(100, 30)
@export var follow_snap_distance: float = 2.0

@export var MAXSPEED: float = 300.0
@export var ACCELERATION: float = 600.0
@export var turn_reset_dot_threshold: float = 0.0

@export var skate_fade_in_seconds: float = 0.15
@export var skate_fade_out_seconds: float = 0.2
@export var skate_muted_volume_db: float = -80.0

var _follow_target: Node2D
var _was_input_active: bool = false

var _is_following: bool = false
var _current_dir: Vector2 = Vector2.ZERO
var _current_speed: float = 0.0

var _skate_requester: String = ""
var _is_skating: bool = false

func _is_player_input_active() -> bool:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	return input_dir.length_squared() > 0.0001

func _ready() -> void:
	_resolve_follow_target()
	_skate_requester = "ski_npc_%s" % str(get_instance_id())

func _physics_process(delta: float) -> void:
	if not follow_enabled:
		return
	if not visible:
		return

	if _follow_target == null or not is_instance_valid(_follow_target):
		_resolve_follow_target()
		return

	var input_active := _is_player_input_active()
	if input_active:
		_was_input_active = true
		_stop_follow()
		move_and_slide()
		return

	if _was_input_active:
		_was_input_active = false
		_start_follow()

	if not _is_following:
		move_and_slide()
		return

	var target := _follow_target.global_position + follow_offset
	var to_target := target - global_position
	var distance := to_target.length()
	if distance <= follow_snap_distance:
		global_position = target
		_stop_follow()
		move_and_slide()
		return

	var desired_dir := to_target / distance
	if _current_dir == Vector2.ZERO:
		_current_dir = desired_dir
		_current_speed = 0.0
	else:
		var dot := _current_dir.dot(desired_dir)
		if dot < turn_reset_dot_threshold:
			_current_speed = 0.0
		_current_dir = desired_dir

	_current_speed = minf(MAXSPEED, _current_speed + ACCELERATION * delta)
	velocity = _current_dir * _current_speed
	_set_skate_sfx_active(true)
	move_and_slide()

func _exit_tree() -> void:
	set_follow_enabled(false)

func set_follow_enabled(active: bool) -> void:
	if follow_enabled == active:
		return
	follow_enabled = active
	if follow_enabled:
		_was_input_active = _is_player_input_active()
		_stop_follow()
		return
	_was_input_active = false
	_stop_follow()

func set_follow_target(target: Node2D) -> void:
	_follow_target = target

func _start_follow() -> void:
	_is_following = true
	_current_dir = Vector2.ZERO
	_current_speed = 0.0
	velocity = Vector2.ZERO

func _stop_follow() -> void:
	_is_following = false
	_current_dir = Vector2.ZERO
	_current_speed = 0.0
	velocity = Vector2.ZERO
	_set_skate_sfx_active(false)

func _resolve_follow_target() -> void:
	_follow_target = null

	if follow_target_path != NodePath() and has_node(follow_target_path):
		_follow_target = get_node(follow_target_path) as Node2D
		return

	var parent := get_parent()
	if parent == null:
		return
	_follow_target = parent.get_node_or_null("ski_player") as Node2D

func _set_skate_sfx_active(active: bool) -> void:
	if _is_skating == active:
		return
	_is_skating = active
	SoundManager.request_loop_sfx("SkiSkate", _skate_requester, active, skate_fade_in_seconds, skate_fade_out_seconds, skate_muted_volume_db)
