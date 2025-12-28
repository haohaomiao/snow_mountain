extends Node

const CURSOR_ARROW := preload("res://assets/cursor/cursor_arrow.png")
const CURSOR_INTERACT := preload("res://assets/cursor/cursor_link.png")

func _ready() -> void:
	set_default()

func set_default() -> void:
	Input.set_custom_mouse_cursor(CURSOR_ARROW)

func set_interactable() -> void:
	Input.set_custom_mouse_cursor(CURSOR_INTERACT)

