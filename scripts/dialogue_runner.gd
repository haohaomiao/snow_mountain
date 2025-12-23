extends Control
class_name DialogueRunner

signal line_changed(line: DialogueLine)
signal choices_requested(choices: Array[String])
signal choice_made(index: int)
signal act_finished

var is_active: bool = false
var _act: DialogueAct = preload("res://acts/NPC/Day1.tres")
var _index: int = 0
var _waiting_for_choice := false
var _return_stack: Array[Dictionary] = []

@onready var _choices_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Choices
@onready var _click_catcher: Button = $PanelContainer/ClickCatcher

func _ready() -> void:
	_set_click_catcher_enabled(true)
# ========= 对外 API =========

func start_act(act: DialogueAct) -> void:
	if act == null:
		return

	_act = act
	_index = 0
	_waiting_for_choice = false
	_return_stack.clear()
	_clear_choices()
	_set_click_catcher_enabled(true)
	is_active = true

	_play_current_line()
func advance() -> void:
	if _waiting_for_choice:
		return
	_index += 1
	_play_current_line()
	
func choose(index: int) -> void:
	# UI 告诉 Runner：玩家选了第几个
	if not _waiting_for_choice:
		return

	var line: DialogueLine = _act.lines[_index]
	if index < 0 or index >= line.choice_branches.size():
		return
	var branch_act: DialogueAct = line.choice_branches[index]
	if branch_act == null:
		return

	_waiting_for_choice = false
	_set_click_catcher_enabled(true)
	_clear_choices()
	emit_signal("choice_made", index)

	_return_stack.push_back({
		"act": _act,
		"index": _index + 1,
	})
	_act = branch_act
	_index = 0
	_play_current_line()
	
func _play_current_line() -> void:
	if _index >= _act.lines.size():
		if not _return_stack.is_empty():
			var frame: Dictionary = _return_stack.pop_back() as Dictionary
			_act = frame["act"]
			_index = frame["index"]
			_play_current_line()
			return

		emit_signal("act_finished")
		is_active = false
		return

	var line: DialogueLine = _act.lines[_index]
	emit_signal("line_changed", line)
	%SpeakText.text = line.text
	%Speaker.text = line.get_speaker_name()
	_clear_choices()
	if line.has_choices:
		_waiting_for_choice = true
		_set_click_catcher_enabled(false)
		emit_signal("choices_requested", line.choices)
		_render_choices(line)
	else:
		_waiting_for_choice = false
		_set_click_catcher_enabled(true)

func _clear_choices() -> void:
	for child in _choices_container.get_children():
		child.queue_free()

func _set_click_catcher_enabled(enabled: bool) -> void:
	_click_catcher.disabled = not enabled
	_click_catcher.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

func _render_choices(line: DialogueLine) -> void:
	for i in line.choices.size():
		var button := Button.new()
		button.text = line.choices[i]
		var has_target := i < line.choice_branches.size() and line.choice_branches[i] != null
		button.disabled = not has_target
		button.pressed.connect(choose.bind(i))
		_choices_container.add_child(button)

# =========  =========


func _on_button_pressed() -> void:
	print('按钮点击')
	advance() # Replace with function body.
