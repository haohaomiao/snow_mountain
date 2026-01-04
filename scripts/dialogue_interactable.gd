class_name DialogueInteractable
extends Interactable

const Subject = SubjectProgress.Subject

@export var subject: Subject = Subject.NPC
@export var start_sfx_name: String = "TalkingStart"
@export var start_delay_seconds: float = 0.35
@export var auto_disable_when_exhausted: bool = true

var _director: DialogueDirector

func _ready() -> void:
	_director = _get_dialogue_director()
	_bind_director_signals()

	if auto_disable_when_exhausted and _director != null:
		var day := GameState.day
		if not _director.has_next_act(day, subject):
			_disable_interaction()

func interact() -> void:
	super.interact()

	if _director == null:
		_director = _get_dialogue_director()
		_bind_director_signals()

	if _director == null:
		push_warning("DialogueInteractable: DialogueDirector not found in current scene.")
		return

	var day := GameState.day
	if auto_disable_when_exhausted and not _director.has_next_act(day, subject):
		_disable_interaction()
		return

	if not start_sfx_name.is_empty():
		SoundManager.play_sfx(start_sfx_name)
		if start_delay_seconds > 0.0:
			await get_tree().create_timer(start_delay_seconds).timeout

	_director.request_dialogue(day, subject)

func _get_dialogue_director() -> DialogueDirector:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	var node := scene.find_child("DialogueDirector", true, false)
	return node as DialogueDirector

func _bind_director_signals() -> void:
	if _director == null:
		return

	var cb := _on_director_dialogue_finished
	if not _director.dialogue_finished.is_connected(cb):
		_director.dialogue_finished.connect(cb)

func _disable_interaction() -> void:
	input_pickable = false
	monitoring = false
	monitorable = false
	CursorManager.set_default()

func _on_director_dialogue_finished(day: int, finished_subject: Subject) -> void:
	if finished_subject != subject:
		return
	if auto_disable_when_exhausted and _director != null and not _director.has_next_act(day, subject):
		_disable_interaction()
