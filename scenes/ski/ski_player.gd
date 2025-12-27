extends CharacterBody2D

var dir := Vector2.from_angle(deg_to_rad(-30.0))
const SPEED = 300

func _physics_process(delta: float) -> void:
	var _input_direction := Input.get_vector("left", "right", "up", "down")
	var input_direction = Input.get_axis("left", "right") * dir
	var move_direction = input_direction.orthogonal()*-1
	velocity = move_direction * SPEED
	move_and_slide()
