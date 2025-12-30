extends Interactable

func interact() -> void:
	var p := SoundManager.play_sfx("DoorInteract")
	if p:
		await p.finished
	GameState.day += 1
	EventBus.go("ski")
