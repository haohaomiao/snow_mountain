extends Node2D
@export_group('bgm')
@export var day_1_2_3_bgm : AudioStream
@export var day_4_bgm : AudioStream
@export var day_5_bgm : AudioStream

@export_group('look')
@export var normal_look : PackedScene
@export var day2_look : PackedScene
@export var intro_look : PackedScene
@export var christmas_look : PackedScene
@onready var look_path: NodePath = "VisualObjects/Look"
@onready var day_3: Marker2D = $VisualObjects/Objectives/BarNPC/Day3
@onready var day_4: Marker2D = $VisualObjects/Objectives/BarNPC/Day4
@onready var bar_npc: Node2D = $VisualObjects/Objectives/BarNPC
@onready var bar_npc_interactable: Area2D = $VisualObjects/Objectives/BarNPC/NPCInteractable

var bgm : AudioStream
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_bgm()
	match_look()
	apply_npc_visibility()
	set_npc_pos()
	SoundManager.play_bgm(bgm)
	SoundManager.play_sfx('BarWind')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_npc_pos() -> void:
	if not _is_npc_day(GameState.day):
		return

	match GameState.day:
		3:
			bar_npc.global_position = day_3.global_position
		4:
			bar_npc.global_position = day_4.global_position

func match_bgm() -> void:
	match GameState.day:
		4:
			bgm = day_4_bgm
		5:
			bgm = day_5_bgm
		_:
			bgm = day_1_2_3_bgm

func match_look() -> void:
	var look_scene := normal_look
	match GameState.day:
		1, 3:
			look_scene = normal_look
		2:
			look_scene = day2_look
		4:
			look_scene = intro_look
		5:
			look_scene = christmas_look
		_:
			look_scene = normal_look

	instantiate_under(look_path, look_scene)

func apply_npc_visibility() -> void:
	var should_show := _is_npc_day(GameState.day)
	bar_npc.visible = should_show

	if bar_npc_interactable != null:
		if not should_show:
			bar_npc_interactable.input_pickable = false
			bar_npc_interactable.monitoring = false
			bar_npc_interactable.monitorable = false

func _is_npc_day(day: int) -> bool:
	return day >= 2 and day <= 4
			
func instantiate_under(path: NodePath, scene: PackedScene) -> Node:
	var parent := get_node_or_null(path)
	if parent == null:
		push_warning("Bar: Look node not found at %s" % path)
		return null

	for child in parent.get_children():
		child.queue_free()

	if scene == null:
		push_warning("Bar: look scene is null for day %d" % GameState.day)
		return null

	var inst := scene.instantiate()
	parent.add_child(inst)
	return inst
