extends CanvasLayer

@onready var panel: Control = $Panel
@onready var label: Label = $Panel/Label

const DIALOGUES := {
    "bar_day1": [
        "（风从门缝里钻进来。）",
        "老板：外面风很大。",
        "旅人：只是路还没走完。",
    ],
    "test": [
        "Hello 1",
        "Hello 2",
    ],
}

var active: bool = false
var lines: Array[String] = []
var idx: int = 0

func _ready() -> void:
    panel.visible = false
    label.text = ""

    EventBus.request_dialogue.connect(_on_request_dialogue)

func _on_request_dialogue(dialogue_id: String) -> void:
    start(dialogue_id)

func start(dialogue_id: String) -> void:
    lines = DIALOGUES.get(dialogue_id, null)

    dialogue_id = dialogue_id
    idx = 0
    active = true

    panel.visible = true
    show_current()

func show_current() -> void:
    label.text = lines[idx]

func next() -> void:
    idx += 1
    if idx >= lines.size():
        EventBus.dialogue_finished.emit()
        return
    show_current()


    
