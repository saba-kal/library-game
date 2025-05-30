shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 color : source_color = vec4(1.0f);
uniform float flow_speed = 0.2f;
uniform float noise_scale = 1.0f;
uniform sampler2D noise_texture : source_color;

void fragment() {
	vec2 uv = vec2(UV.x * 0.2, UV.y);
	vec4 textureColor = texture(noise_texture, uv * noise_scale + vec2(TIME * flow_speed, 0));
	ALBEDO = textureColor.rgb * color.rgb * 10.0;
	ALPHA = UV.x * UV.x * textureColor.r;
}
