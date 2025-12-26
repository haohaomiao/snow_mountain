class_name Interactable
extends Area2D

signal interacted
func _init() -> void:
	input_pickable = true
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	input_event.connect(_on_input_event)

func interact() -> void:
	print("[Interact] %s" % name)
	interacted.emit()

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		interact()
#这里可能需要实现一个鼠标manager
func _on_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(preload("res://assets/cursor/cursor_link.png"))
	
func _mouse_exited() -> void:
	#Input.set_custom_mouse_cursor(preload("res://assets/cursor/cursor_arrow.png"))
	Input.set_custom_mouse_cursor(null)
