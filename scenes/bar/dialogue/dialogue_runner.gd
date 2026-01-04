extends Control
class_name DialogueRunner

signal line_changed(line: DialogueLine)
signal choices_requested(choices: Array[String])
signal choice_made(index: int)
signal act_finished

var is_active: bool = false
var _act: DialogueAct
var _index: int = 0
var _waiting_for_choice := false
var _return_stack: Array[Dictionary] = []
@export var bn_theme: StyleBoxFlat
@export var font: Font
@export var typing_min_seconds: float = 0.5
@export var typing_seconds_per_char: float = 0.05 # 10 字 ≈ 0.5s
@export var typing_punct_pause_seconds: float = 0.1
@export var typing_fade_out_seconds: float = 0.1
@export var choice_button_font_size: int = 14
@export var choice_button_min_height: float = 24.0
@export_group('portrait')
@export var player_portraits: Array[Texture2D]
@export var npc_portraits: Array[Texture2D]

var voice: AudioStreamPlayer
var _voice_fade_tween: Tween
var _voice_initial_volume_db_by_name: Dictionary = {}

var _typing_session_id: int = 0
var _is_typing: bool = false
var _current_line: DialogueLine
@onready var _choices_container: VBoxContainer = %ChoicesContainer
@onready var _click_catcher: Button = %ClickCatcher

func _ready() -> void:
	_click_catcher.pressed.connect(SoundManager.play_sfx.bind('WindowClick'))
	close()
	get_viewport().gui_focus_changed.connect(func(c):
		print("Focus -> ", c)
	)
# ========= 对外 API =========
func start_act(act: DialogueAct) -> void:
	if act == null:
		return
	if is_active:
		return

	_cancel_typing()
	_stop_typing_sfx(true)
	_act = act
	_index = 0
	_waiting_for_choice = false
	_return_stack.clear()
	_clear_choices()
	_set_click_catcher_enabled(true)
	is_active = true
	open()

	_play_current_line()

func open() -> void:
	visible = true

func close() -> void:
	_cancel_typing()
	_stop_typing_sfx(true)
	is_active = false
	_waiting_for_choice = false
	_return_stack.clear()
	_clear_choices()
	_set_click_catcher_enabled(false)
	visible = false

func advance() -> void:
	if _waiting_for_choice:
		return
	if _is_typing:
		_skip_current_line()
		return
	_index += 1
	_play_current_line()
	
func choose(index: int) -> void:
	# UI 告诉 Runner：玩家选了第几个
	if not _waiting_for_choice:
		return

	var line: DialogueLine = _act.lines[_index]
	if index < 0 or index >= line.choices.size():
		return
		
	_waiting_for_choice = false
	_set_click_catcher_enabled(true)
	_clear_choices()
	emit_signal("choice_made", index)

	var branch_act: DialogueAct = null
	if index < line.choice_branches.size():
		branch_act = line.choice_branches[index]
		if branch_act == null:
			return

	if branch_act == null:
		_index += 1
		_play_current_line()
		return

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
		close()
		return

	var line: DialogueLine = _act.lines[_index]
	_apply_portrait(line)
	emit_signal("line_changed", line)
	_current_line = line
	%SpeakText.text = ""
	_clear_choices()
	_waiting_for_choice = false
	_set_click_catcher_enabled(true)
	_start_typewriter(line)

func _apply_portrait(line: DialogueLine):
	match line.speaker:
		DialogueLine.Speaker.PLAYER:
			%Portrait.texture = player_portraits[line.portrait]
		DialogueLine.Speaker.SKIER:
			%Portrait.texture = npc_portraits[line.portrait]

func _cancel_typing() -> void:
	_typing_session_id += 1
	_is_typing = false
	_current_line = null

func _skip_current_line() -> void:
	if not _is_typing:
		return

	var line := _current_line
	_cancel_typing()
	if line != null:
		%SpeakText.text = line.text
		%SpeakText.visible_characters = -1
	_stop_typing_sfx(false)
	_after_line_fully_shown(line)

func _start_typewriter(line: DialogueLine) -> void:
	_cancel_typing()

	var session_id := _typing_session_id
	_is_typing = true
	_current_line = line
	%SpeakText.text = line.text
	%SpeakText.visible_characters = 0

	var scroll := %SpeakText.get_parent() as ScrollContainer
	if scroll != null:
		scroll.scroll_horizontal = 0
		scroll.scroll_vertical = 0

	_stop_typing_sfx(true)
	var effective_len := _get_effective_text_length(line.text)
	if effective_len > 0:
		_start_typing_sfx_for_speaker(line.speaker)

	_run_typewriter(session_id, line, effective_len)

func _run_typewriter(session_id: int, line: DialogueLine, effective_len: int) -> void:
	var full_text := line.text
	var target_duration := max(typing_min_seconds, typing_seconds_per_char * float(effective_len)) as float
	var start_ms := Time.get_ticks_msec()
	var per_char_delay := _get_effective_char_delay_seconds(effective_len)
	var i := 0

	while i < full_text.length():
		if session_id != _typing_session_id:
			return

		var special := _consume_special_punctuation(full_text, i)
		if special["count"] > 0:
			var count := int(special["count"])
			var next_index := i + count
			%SpeakText.visible_characters = next_index
			if _has_effective_char_after(full_text, next_index):
				await _punctuation_pause(session_id)
			i = next_index
			continue

		var ch := full_text.substr(i, 1)
		%SpeakText.visible_characters = i + 1
		print(i)

		var has_more_effective := _has_effective_char_after(full_text, i + 1)
		if _is_whitespace_char(ch):
			i += 1
			continue

		if _is_punctuation_char(ch):
			if has_more_effective:
				await _punctuation_pause(session_id)
		else:
			if has_more_effective and per_char_delay > 0.0:
				await get_tree().create_timer(per_char_delay).timeout

		i += 1

	if session_id != _typing_session_id:
		return
	%SpeakText.visible_characters = -1

	var elapsed_seconds := float(Time.get_ticks_msec() - start_ms) / 1000.0
	var remaining_seconds := target_duration - elapsed_seconds as float
	if remaining_seconds > 0.0:
		await get_tree().create_timer(remaining_seconds).timeout
		if session_id != _typing_session_id:
			return

	_is_typing = false
	_stop_typing_sfx(false)
	_after_line_fully_shown(line)

func _after_line_fully_shown(line: DialogueLine) -> void:
	if line == null:
		return

	_clear_choices()
	if line.has_choices:
		_waiting_for_choice = true
		_set_click_catcher_enabled(false)
		emit_signal("choices_requested", line.choices)
		_render_choices(line)
	else:
		_waiting_for_choice = false
		_set_click_catcher_enabled(true)

func _punctuation_pause(session_id: int) -> void:
	if session_id != _typing_session_id:
		return

	_pause_typing_sfx()
	if typing_punct_pause_seconds > 0.0:
		await get_tree().create_timer(typing_punct_pause_seconds).timeout

	if session_id != _typing_session_id:
		return

	_resume_typing_sfx()

func _start_typing_sfx_for_speaker(speaker: DialogueLine.Speaker) -> void:
	var sfx_name := "NpcTyping"
	if speaker == DialogueLine.Speaker.PLAYER:
		sfx_name = "PlayerTyping"

	voice = SoundManager.play_sfx(sfx_name)
	if voice == null:
		return

	var initial_volume_db := _get_voice_initial_volume_db(voice)
	voice.volume_db = initial_volume_db
	voice.stream_paused = false

func _stop_typing_sfx(immediate: bool) -> void:
	if _voice_fade_tween != null:
		_voice_fade_tween.kill()
		_voice_fade_tween = null

	if voice == null:
		return

	var player := voice
	var initial_volume_db := _get_voice_initial_volume_db(player)
	player.stream_paused = false

	if immediate or typing_fade_out_seconds <= 0.0:
		player.stop()
		player.volume_db = initial_volume_db
		return

	_voice_fade_tween = create_tween()
	_voice_fade_tween.tween_property(player, "volume_db", -80.0, typing_fade_out_seconds)
	_voice_fade_tween.tween_callback(func() -> void:
		player.stop()
		player.volume_db = initial_volume_db
	)

func _pause_typing_sfx() -> void:
	if voice == null:
		return
	if voice.playing:
		voice.stream_paused = true

func _resume_typing_sfx() -> void:
	if voice == null:
		return
	voice.stream_paused = false

func _get_voice_initial_volume_db(player: AudioStreamPlayer) -> float:
	var key := player.name
	if not _voice_initial_volume_db_by_name.has(key):
		_voice_initial_volume_db_by_name[key] = player.volume_db
	return float(_voice_initial_volume_db_by_name[key])

func _get_effective_char_delay_seconds(effective_len: int) -> float:
	var duration := max(typing_min_seconds, typing_seconds_per_char * float(effective_len)) as float
	var denom := max(1, effective_len - 1) as float
	return duration / float(denom)

func _get_effective_text_length(text: String) -> int:
	var length := 0
	for i in text.length():
		var ch := text.substr(i, 1)
		if _is_whitespace_char(ch):
			continue
		if _is_punctuation_char(ch):
			continue
		length += 1
	return length

func _consume_special_punctuation(text: String, start_index: int) -> Dictionary:
	var ch := text.substr(start_index, 1)
	if ch == ".":
		var run := _count_run(text, start_index, ".")
		if run >= 3:
			return {"text": text.substr(start_index, run), "count": run}
	elif ch == "…":
		var run := _count_run(text, start_index, "…")
		return {"text": text.substr(start_index, run), "count": run}
	elif ch == "—":
		var run := _count_run(text, start_index, "—")
		if run >= 2:
			return {"text": text.substr(start_index, run), "count": run}
	return {"text": "", "count": 0}

func _count_run(text: String, start_index: int, ch: String) -> int:
	var i := start_index
	while i < text.length() and text.substr(i, 1) == ch:
		i += 1
	return i - start_index

func _has_effective_char_after(text: String, from_index: int) -> bool:
	for i in range(from_index, text.length()):
		var ch := text.substr(i, 1)
		if _is_whitespace_char(ch):
			continue
		if _is_punctuation_char(ch):
			continue
		return true
	return false

func _is_whitespace_char(ch: String) -> bool:
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r" or ch == "　"

const _PUNCTUATION_CHARS := {
	"。": true,
	".": true,
	"，": true,
	",": true,
	"？": true,
	"?": true,
	"！": true,
	"!": true,
	"：": true,
	":": true,
	"；": true,
	";": true,
	"、": true,
	"（": true,
	"）": true,
	"(": true,
	")": true,
	"【": true,
	"】": true,
	"[": true,
	"]": true,
	"《": true,
	"》": true,
	"「": true,
	"」": true,
	"『": true,
	"』": true,
	"“": true,
	"”": true,
	"\"": true,
	"‘": true,
	"’": true,
	"'": true,
	"…": true,
	"—": true,
	"-": true,
	"－": true,
	"·": true,
	"～": true,
	"~": true,
}

func _is_punctuation_char(ch: String) -> bool:
	return _PUNCTUATION_CHARS.has(ch)

func _clear_choices() -> void:
	for child in _choices_container.get_children():
		child.queue_free()

func _set_click_catcher_enabled(enabled: bool) -> void:
	_click_catcher.disabled = not enabled
	_click_catcher.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

func _render_choices(line: DialogueLine) -> void:
	for i in line.choices.size():
		var button := Button.new()
		button.add_theme_font_override("font",font)
		button.add_theme_stylebox_override("normal", bn_theme)
		button.add_theme_font_size_override("font_size", 24)
		button.text = line.choices[i]
		var explicitly_disabled := i < line.choice_branches.size() and line.choice_branches[i] == null
		button.disabled = explicitly_disabled
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if choice_button_min_height > 0.0:
			button.custom_minimum_size.y = choice_button_min_height
		if choice_button_font_size > 0:
			button.add_theme_font_size_override("font_size", choice_button_font_size)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.x = 200
		button.pressed.connect(choose.bind(i))
		button.pressed.connect(SoundManager.play_sfx.bind('WindowClick'))
		button.mouse_entered.connect(SoundManager.play_sfx.bind('WindowFocus'))
		_choices_container.add_child(button)

# =========  =========


func _on_button_pressed() -> void:
	advance()
