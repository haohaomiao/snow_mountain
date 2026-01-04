extends Node2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match GameState.day:
		3:
			sprite.animation = &"default"
		4:
			sprite.animation = &"sit_left"
