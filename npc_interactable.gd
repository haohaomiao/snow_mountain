extends Interactable

const Subject = SubjectProgress.Subject

@export var subject: Subject = Subject.NPC

var _director: DialogueDirector

func _ready() -> void:
	_director = _get_dialogue_director()
	if _director != null:
		_director.dialogue_finished.connect(_on_director_dialogue_finished)
		var day := GameState.day
		if not _director.has_next_act(day, subject):
			_disable_interaction()

func interact() -> void:
	if _director == null:
		_director = _get_dialogue_director()

	if _director == null:
		push_warning("NPCInteractable: DialogueDirector not found in current scene.")
		return

	var day := GameState.day
	if not _director.has_next_act(day, subject):
		_disable_interaction()
		return

	_director.request_dialogue(day, subject)

func _get_dialogue_director() -> DialogueDirector:
	var scene := get_tree().current_scene
	if scene == null:
		return null

	var node := scene.find_child("DialogueDirector", true, false)
	return node as DialogueDirector

func _disable_interaction() -> void:
	input_pickable = false
	monitoring = false
	monitorable = false
	CursorManager.set_default()

func _on_director_dialogue_finished(day: int, finished_subject: Subject) -> void:
	if finished_subject != subject:
		return
	if _director != null and not _director.has_next_act(day, subject):
		_disable_interaction()
