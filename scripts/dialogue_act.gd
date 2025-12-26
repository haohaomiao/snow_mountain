extends Resource
class_name DialogueAct

@export var act_id: String = "Day1"
@export var day_index: int = 1

## —— 正式对话内容 ——

@export var lines: Array[DialogueLine] = []
