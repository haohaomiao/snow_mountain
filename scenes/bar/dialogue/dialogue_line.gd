extends Resource
class_name DialogueLine

enum Speaker{
	PLAYER,
	SKIER
}

enum Portrait{
	DEFAULT,
	SMILE,
	SAD,
	UNEXPECTED
}

const SPEAKER_NAME := {
	Speaker.PLAYER: "Player",
	Speaker.SKIER: "NPC",
}
func get_speaker_name() -> String:
	var names := SPEAKER_NAME if GameState.english else {
		Speaker.PLAYER: "玩家",
		Speaker.SKIER: "NPC",
	}

	return names.get(speaker, "Unknown")

@export var speaker: Speaker = Speaker.PLAYER
@export var portrait: Portrait = Portrait.DEFAULT
@export_multiline var text: String = ""

@export var has_choices: bool = false
@export var choices: Array[String] = []
@export var choice_branches: Array[DialogueAct] = []
