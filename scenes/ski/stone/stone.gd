extends Area2D
class_name Obstacle

@export var speed := 50
@export var kill_x := 648.0   # 超过这个 y 就销毁（按你分辨率改）
var _hit := false

func _process(delta: float) -> void:
    position += transform.x * speed * delta
    if position.x > kill_x:
        queue_free()
        
func _on_body_entered(body: Node) -> void:
    print("hit")
    # 可选：立刻停掉石头本身（避免继续触发）
    set_deferred("monitoring", false)
    EventBus.crashed.emit()
