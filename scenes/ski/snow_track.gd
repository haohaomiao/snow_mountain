extends Parallax2D
@onready var track_a: Sprite2D = $TrackA
@onready var track_b: Sprite2D = $TrackB

# 参数
var dir := Vector2(-1, 0.3).normalized()     # 滑行方向（右下45°）
var speed := 200.0                        # 像素/秒
var segment_len := 600.0                  # 一段雪道沿 dir 的长度（手填/后面再算）
var recycle_margin := 100.0               # 安全余量（防止露缝）

# 每帧
func _process(delta):
    var step := -dir * speed * delta as Vector2
    track_a.position += step
    track_b.position += step
    
    # 用投影标量判断前后（沿 dir 越大越“在前方”）
    var ta := track_a.position.dot(dir)
    var tb := track_b.position.dot(dir)

    var front = track_a
    var back  = track_b
    var t_front = ta
    var t_back  = tb
    if tb > ta:
        front = track_b; back = track_a
        t_front = tb;  t_back = ta

    # 回收条件：back 比 front 落后超过一段长度（加 margin）
    if (t_front - t_back) >= (segment_len + recycle_margin):
        print(t_front - t_back)
        back.position = front.position + dir * segment_len
