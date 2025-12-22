extends Node2D
const Phase = GameState.Phase
var _running := false

func _enter_tree():
    print("enter bar tree")
    #EventBus.phase_changed.connect(_on_phase_changed)
#
#func _exit_tree():
    #if EventBus.phase_changed.is_connected(_on_phase_changed):
        #EventBus.phase_changed.disconnect(_on_phase_changed)
func _ready() -> void:
    _running = true
    _run_bar()

func _run_bar() -> void:
    var day := GameState.day
    match day:
        1:
            pass
        2:
            pass
        3:
            pass
        4:
            pass
        5:
            pass
        _:
            pass

    # 这里你大概率会 await 对话结束
    # 示例：先用 timer 顶着
    await get_tree().create_timer(2.0).timeout
    _running = false
    EventBus.complete_phase({"day": day})
