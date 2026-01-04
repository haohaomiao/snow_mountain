extends Interactable
var p : AudioStreamPlayer
func interact() -> void:
	input_pickable = false
	p = SoundManager.play_sfx("DoorInteract")
	if p:
		await p.finished
	EventBus.next_day()
	EventBus.go("ski")
