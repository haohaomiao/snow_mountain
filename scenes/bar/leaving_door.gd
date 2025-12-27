extends Interactable

func interact() -> void:
	var p := SoundManager.play_sfx("DoorInteract")
	if p:
		await p.finished
	EventBus.go("ski")
