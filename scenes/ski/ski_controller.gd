extends Node2D

@export var scroll_dir := Vector2(1, 1)
@export var uv_speed := 1.5
@export var snow_sprite_path: NodePath = NodePath("Map/Parallax2D2/TestBackGround")

var _uv_offset := Vector2.ZERO
var _snow_sprite: Sprite2D
var _snow_material: ShaderMaterial

func _ready() -> void:
	_snow_sprite = get_node_or_null(snow_sprite_path) as Sprite2D
	if _snow_sprite == null:
		push_warning("SkiController: snow_sprite_path not found: %s" % snow_sprite_path)
		set_process(false)
		return

	_snow_material = _snow_sprite.material as ShaderMaterial
	if _snow_material == null:
		push_warning("SkiController: Snow sprite has no ShaderMaterial (material is %s)." % [typeof(_snow_sprite.material)])
		set_process(false)
		return

func _process(delta: float) -> void:
	var dir := scroll_dir.normalized()
	_uv_offset += (-dir) * uv_speed * delta
	_uv_offset = _uv_offset.posmod(1.0)
	_snow_material.set_shader_parameter("uv_offset", _uv_offset)
