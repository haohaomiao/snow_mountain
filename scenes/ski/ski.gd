extends Node2D

var _running := false
const Phase = GameState.Phase
func _enter_tree():
    print("enter ski tree")
    # EventBus.phase_changed.connect(_on_phase_changed)

# func _exit_tree():
    # if EventBus.phase_changed.is_connected(_on_phase_changed):
        # EventBus.phase_changed.disconnect(_on_phase_changed)

func _ready() -> void:
    print("copy that!")
    _running = true
    _run_ski()

func _run_ski() -> void:
    var day := GameState.day
    print("ski day ",day)
    # 这里就是你要的：场景自己按 day 处理细节
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
        6:
            pass
        _:
            pass

    # 用 await 模拟“这一天的滑雪过程”
    await get_tree().create_timer(2.0).timeout
    # 这一行后续要注释掉
    print("ski finished!")
    _running = false
    EventBus.complete_phase({"day": day, "success": true})
