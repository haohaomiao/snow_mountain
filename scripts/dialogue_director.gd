extends Node
class_name DialogueDirector

enum Subject {
	NPC,
}

signal dialogue_started(day: int, subject: Subject, act: DialogueAct)
signal dialogue_finished(day: int, subject: Subject)

@export var acts_root: String = "res://acts"
@export var runner_path: NodePath

var is_active: bool = false
var is_busy: bool = false

var _runner: DialogueRunner
var _current_day: int = -1
var _current_subject: int = -1

func _ready() -> void:
	_runner = get_node_or_null(runner_path) as DialogueRunner
	if _runner == null:
		push_warning("DialogueDirector: runner_path is not set or does not point to a DialogueRunner.")
		return

	_runner.act_finished.connect(_on_runner_act_finished)
	is_active = _runner.is_active

func request_dialogue(day: int, subject: Subject) -> bool:
	if _runner == null:
		return false
	if is_busy or is_active or _runner.is_active:
		return false

	is_busy = true
	var act := resolve_act(day, subject)
	if act == null:
		is_busy = false
		return false

	_current_day = day
	_current_subject = subject
	is_active = true
	emit_signal("dialogue_started", day, subject, act)
	_runner.start_act(act)
	is_busy = false
	return true

func resolve_act(day: int, subject: Subject) -> DialogueAct:
	var subject_name := Subject.find_key(subject) as Subject
	if subject_name == null:
		return null

	var root := acts_root.trim_suffix("/")
	var path := "%s/%s/Day%d.tres" % [root, subject_name, day]
	if not ResourceLoader.exists(path):
		return null

	return load(path) as DialogueAct

func _on_runner_act_finished() -> void:
	if not is_active:
		return

	is_active = false
	var finished_day := _current_day
	var finished_subject := _current_subject
	_current_day = -1
	_current_subject = -1
	emit_signal("dialogue_finished", finished_day, finished_subject)
