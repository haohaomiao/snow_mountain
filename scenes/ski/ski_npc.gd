extends CharacterBody2D
class_name SkiNpc

@export var follow_enabled: bool = false
@export var follow_target_path: NodePath = NodePath("../ski_player")
@export var follow_offset: Vector2 = Vector2(100, 30)
@export var follow_speed: float = 300.0
@export var follow_min_tween_seconds: float = 0.05
@export var follow_max_tween_seconds: float = 0.25
@export var follow_snap_distance: float = 2.0

var _follow_target: Node2D
var _follow_tween: Tween
var _was_input_active: bool = false

func _ready() -> void:
	_resolve_follow_target()

func _process(delta: float) -> void:
	if not follow_enabled:
		return
	if not visible:
		return

	if _follow_target == null or not is_instance_valid(_follow_target):
		_resolve_follow_target()
		return

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var input_active := input_dir.length_squared() > 0.0001
	if input_active:
		_was_input_active = true
		_stop_follow_tween()
		return
	if not _was_input_active:
		return
	_was_input_active = false

	var target := _follow_target.global_position + follow_offset
	var distance := global_position.distance_to(target)
	if distance <= follow_snap_distance:
		return

	var speed := maxf(1.0, follow_speed)
	var duration := clampf(distance / speed, follow_min_tween_seconds, follow_max_tween_seconds)

	if _follow_tween != null:
		_follow_tween.kill()
	_follow_tween = create_tween()
	_follow_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_follow_tween.tween_property(self, "global_position", target, duration)

func _exit_tree() -> void:
	set_follow_enabled(false)

func set_follow_enabled(active: bool) -> void:
	if follow_enabled == active:
		return
	follow_enabled = active
	if follow_enabled:
		_was_input_active = true
		return
	_was_input_active = false
	_stop_follow_tween()

func set_follow_target(target: Node2D) -> void:
	_follow_target = target

func _stop_follow_tween() -> void:
	if _follow_tween == null:
		return
	_follow_tween.kill()
	_follow_tween = null

func _resolve_follow_target() -> void:
	_follow_target = null

	if follow_target_path != NodePath() and has_node(follow_target_path):
		_follow_target = get_node(follow_target_path) as Node2D
		return

	var parent := get_parent()
	if parent == null:
		return
	_follow_target = parent.get_node_or_null("ski_player") as Node2D
