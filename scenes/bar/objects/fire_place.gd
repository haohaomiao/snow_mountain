extends Interactable

var current_anim: StringName
var burning_player: AudioStreamPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $"../AnimatedSprite2D"
	
func interact() -> void:
	current_anim = animated_sprite_2d.animation
	if current_anim == &"default":
		SoundManager.play_sfx('FireLighting')
		burning_player = SoundManager.play_sfx('FireBuring')
		current_anim = &"burning"
		input_pickable = false
	#else:
		#current_anim = &"default"
		#burning_player.stop()

	animated_sprite_2d.play(current_anim)
