extends Node
class_name DialogueDirector

const Subject = SubjectProgress.Subject

signal dialogue_started(day: int, subject: Subject, act: DialogueAct)
signal dialogue_finished(day: int, subject: Subject)

@export var acts_root: String = "res://acts"
@export var runner_path: NodePath

var is_active: bool = false
var is_busy: bool = false

@onready var _runner: DialogueRunner = $DialogueBox

var _current_day: int = -1
var _current_subject: Subject = Subject.NPC

func _get_language_dir() -> String:
	return "en" if GameState.english else "ch"

func _ready() -> void:
	print(_runner, " script=", _runner.get_script())
	print("is DialogueRunner? ", _runner is DialogueRunner)
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

func has_next_act(day: int, subject: Subject) -> bool:
	var day_resource := resolve_day(day, subject)
	if day_resource == null:
		return false

	var act_index := SubjectProgress.get_next_act_index(day, subject)
	if act_index < 0 or act_index >= day_resource.acts.size():
		return false

	return day_resource.acts[act_index] != null

func resolve_act(day: int, subject: Subject) -> DialogueAct:
	var day_resource := resolve_day(day, subject)
	if day_resource == null:
		return null

	var act_index := SubjectProgress.get_next_act_index(day, subject)
	if act_index < 0 or act_index >= day_resource.acts.size():
		return null

	return day_resource.acts[act_index]

func resolve_day(day: int, subject: Subject) -> DialogueDay:
	var subject_name := SubjectProgress.get_subject_name(subject)
	if subject_name.is_empty():
		return null

	var root := acts_root.trim_suffix("/")
	var preferred_lang := _get_language_dir()
	var path := "%s/%s/%s/Day%d.tres" % [root, preferred_lang, subject_name, day]

	if not ResourceLoader.exists(path):
		var fallback_lang := "ch" if preferred_lang == "en" else "en"
		var fallback_path := "%s/%s/%s/Day%d.tres" % [root, fallback_lang, subject_name, day]
		if ResourceLoader.exists(fallback_path):
			path = fallback_path
		else:
			var legacy_path := "%s/%s/Day%d.tres" % [root, subject_name, day]
			if not ResourceLoader.exists(legacy_path):
				return null
			path = legacy_path

	return load(path) as DialogueDay


func _on_runner_act_finished() -> void:
	if not is_active:
		return

	is_active = false
	var finished_day := _current_day
	var finished_subject := _current_subject
	_current_day = -1
	_current_subject = Subject.NPC
	SubjectProgress.advance(finished_day, finished_subject)
	emit_signal("dialogue_finished", finished_day, finished_subject)
