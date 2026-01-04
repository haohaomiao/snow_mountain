extends Node2D
class_name StoneSpawner

@export var stone_scene: PackedScene

# 生成间隔（秒）：每次会在这个范围里随机一个
@export var spawn_interval_min: float = 3
@export var spawn_interval_max: float = 4

# “左下区域”的出生范围（世界坐标 / 或者相对父节点坐标都行）
# 如果你希望“靠左”，就把 x_range 设小一点（比如 30~180）
@export var spawn_x_range := Vector2(30.0, 180.0)

# “左下的一段 y 轴范围”
# 如果你的屏幕高度是 720，左下可能就是 520~700 之类
@export var spawn_y_range := Vector2(520.0, 700.0)

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
    randomize()
    _schedule_next()

func _schedule_next() -> void:
    if spawn_timer == null:
        push_warning("StoneSpawner: missing child Timer node named 'SpawnTimer'.")
        return

    spawn_timer.one_shot = true
    spawn_timer.timeout.connect(_on_spawn_timer_timeout)
    spawn_timer.start(randf_range(spawn_interval_min, spawn_interval_max))

func _on_spawn_timer_timeout() -> void:
    _spawn_one()
    # 下一次也随机
    spawn_timer.start(randf_range(spawn_interval_min, spawn_interval_max))

func _spawn_one() -> void:
    if stone_scene == null:
        push_warning("StoneSpawner: stone_scene is not assigned.")
        return

    var stone := stone_scene.instantiate() as Node2D
    # 通常加到 spawner 的父节点（和玩家/雪道同一层），更好管理层级
    get_parent().add_child(stone)

    var x := randf_range(spawn_x_range.x, spawn_x_range.y)
    var y := randf_range(spawn_y_range.x, spawn_y_range.y)
    stone.position = Vector2(x, y)
