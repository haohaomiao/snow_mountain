extends CanvasLayer

@export var default_duration := 0.25

@onready var _rect: ColorRect = $ColorRect

var _tween: Tween

func _ready() -> void:
    _rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _set_alpha(0.0)
    hide()

func fade_out(duration: float = -1.0) -> void:
    var d := default_duration if duration < 0.0 else duration
    show()
    _kill_tween()
    _tween = create_tween()
    _tween.tween_property(_rect, "color:a", 1.0, d)
    await _tween.finished

func fade_in(duration: float = -1.0) -> void:
    var d := default_duration if duration < 0.0 else duration
    show()
    _kill_tween()
    _tween = create_tween()
    _tween.tween_property(_rect, "color:a", 0.0, d)
    await _tween.finished
    hide()

func _set_alpha(a: float) -> void:
    var c := _rect.color
    c.a = clampf(a, 0.0, 1.0)
    _rect.color = c

func _kill_tween() -> void:
    if _tween != null and _tween.is_running():
        _tween.kill()
    _tween = null
