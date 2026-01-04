extends Node

const Phase = GameState.Phase
signal request_scene(scene_key: String, payload: Dictionary)
signal phase_changed(phase: Phase, payload: Dictionary)
signal phase_completed(phase: Phase, payload: Dictionary)
signal day_changed(cur_day: int)

var debug_log := true

func go(scene_key: String, payload := {}):
	# 考虑之后可能有发信号前做处理的需求，加了一层封装，可以去掉
	if debug_log:
		print("[EventBus] request_scene -> ", scene_key, " ", payload)
	request_scene.emit(scene_key, payload)

func change_phase(payload := {}):
	# 可能包括SKI，BAR，ENDING
	if debug_log:
		print("[EventBus] phase -> ", GameState.phase, " ", payload)
	phase_changed.emit(payload)

func complete_phase(payload := {}):
	if debug_log:
		print("[EventBus] completed -> ", GameState.phase, " ", payload)
	phase_completed.emit(payload)

func next_day():
	GameState.day += 1
	day_changed.emit(GameState.day)
