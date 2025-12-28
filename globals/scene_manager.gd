extends Node
const Phase = GameState.Phase
const SCENES := {
    "ski": "res://scenes/ski/ski.tscn",
    "bar": "res://scenes/bar/bar.tscn",
    #"ending": "res://scenes/Ending.tscn"
}

var _is_changing := false

func _ready():
    EventBus.request_scene.connect(_on_request_scene)

func _on_request_scene(scene_key: String, payload: Dictionary) -> void:
	if _is_changing:
		return
	# 场景切换时强制还原鼠标样式：避免交互区域被销毁导致 mouse_exited 没触发
	CursorManager.set_default()
	var path := str(SCENES.get(scene_key, ""))
	if path == "":
		push_error("Unknown scene_key: %s" % scene_key)
		return

	_is_changing = true
	if Transition:
		await Transition.fade_out()

	get_tree().call_deferred("change_scene_to_file",path)

	# 场景切换要到下一帧才能保证新场景 ready / 已连接信号
	await get_tree().process_frame
	await get_tree().process_frame
	if Transition:
		await Transition.fade_in()
	EventBus.change_phase(payload)
	_is_changing = false
	
