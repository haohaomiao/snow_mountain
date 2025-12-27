shader_type canvas_item;

uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);

void fragment() {
	// 使用 Sprite2D 自身的 TEXTURE，这样更换贴图时不需要同步改 Shader 参数。
	vec2 uv = fract(UV * uv_scale + uv_offset);
	COLOR = texture(TEXTURE, uv);
}
