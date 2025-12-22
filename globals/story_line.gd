extends Node

const LOOP_DAYS := 5
const FINAL_DAY := 6
const Phase = GameState.Phase

func _ready():
    EventBus.phase_completed.connect(_on_phase_completed)

func start():
    GameState.day = 1
    GameState.phase = Phase.SKI
    # 这里的处理后续需要细化修改
    EventBus.go("ski", {"day": GameState.day})
    EventBus.play_bgm.emit("bgm1")

func _on_phase_completed(payload: Dictionary) -> void:
    var day := GameState.day
    if GameState.phase == Phase.SKI:
        if day <= LOOP_DAYS:
            print("let's drink!")
            GameState.phase = Phase.BAR
            EventBus.go("bar", {"day": day})
        elif day == FINAL_DAY:
            GameState.phase = Phase.ENDING
            EventBus.go("ending",{"day": day})
        else:
            push_error("storyline error")

    elif GameState.phase == Phase.BAR:
        GameState.day = day + 1
        GameState.phase = Phase.SKI
        EventBus.go("ski", {"day": GameState.day})
