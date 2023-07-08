shader_type canvas_item;

uniform sampler2D noise_texture;

void fragment() {
	if ( COLOR.a > 0.0 ) {
		vec2 uv = UV;
		uv.x += TIME * 0.01;
		COLOR.r *= 0.60 + (texture(noise_texture, uv).r * 0.40);
	}
}
