extends Resource
class_name DialogueLine

enum Speaker{
	PLAYER,
	SKIER
}

enum Portrait{
	DEFAULT,
	SMILE,
	SERIOUS,
}

const SPEAKER_NAME := {
	Speaker.PLAYER: "Player",
	Speaker.SKIER: "The Skier",
}
func get_speaker_name() -> String:
	return SPEAKER_NAME.get(speaker, "Unknown")

@export var speaker: Speaker = Speaker.PLAYER
@export var portrait: Portrait = Portrait.DEFAULT
@export_multiline var text: String = ""

@export var has_choices: bool = false
@export var choices: Array[String] = []
@export var choice_branches: Array[DialogueAct] = []
