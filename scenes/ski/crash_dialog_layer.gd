extends CanvasLayer
class_name CrashDialogLayer

@onready var dialog: AcceptDialog = $CrashDialog

var _active := false

func _ready() -> void:
    dialog.hide()
    EventBus.crashed.connect(show_crash)
    dialog.confirmed.connect(_on_confirmed)

func show_crash() -> void:
    print("crash!")
    if _active:
        return
    _active = true

    # 可选：冻结玩家操作（如果你不想暂停整个世界，就只禁用玩家脚本更好）
    get_tree().paused = true
    process_mode = Node.PROCESS_MODE_ALWAYS
    dialog.process_mode = Node.PROCESS_MODE_ALWAYS
    dialog.popup_centered()

func _on_confirmed() -> void:
    get_tree().quit()
