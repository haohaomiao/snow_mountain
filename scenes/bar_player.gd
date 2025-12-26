extends CharacterBody2D


const SPEED = 50.0

var last_direction: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	if input_direction != Vector2.ZERO:
		last_direction = input_direction
	velocity = input_direction * SPEED
	move_and_slide()
	_update_animation(input_direction)

func _update_animation(input_direction: Vector2) -> void:
	var motion := "down"
	if last_direction.x != 0:
		motion = "left" if last_direction.x < 0 else "right"
	elif last_direction.y != 0:
		motion = "up" if last_direction.y < 0 else "down"

	var suffix := "_walk" if input_direction != Vector2.ZERO else "_default"
	$AnimatedSprite2D.animation = motion + suffix
