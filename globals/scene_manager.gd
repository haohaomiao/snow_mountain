extends Node
const Phase = GameState.Phase
const SCENES := {
    "ski": "res://scenes/ski/ski.tscn",
    "bar": "res://scenes/bar/bar.tscn",
    "ending": "res://scenes/Ending.tscn"
}

func _ready():
    EventBus.request_scene.connect(_on_request_scene)

func _on_request_scene(scene_key: String, payload: Dictionary) -> void:
    var path := str(SCENES.get(scene_key, ""))
    if path == "":
        push_error("Unknown scene_key: %s" % scene_key)
        return

    get_tree().call_deferred("change_scene_to_file",path)

    # 场景切换要到下一帧才能保证新场景 ready / 已连接信号
    await get_tree().process_frame
    await get_tree().process_frame
    EventBus.change_phase(payload)
    
