shader_type canvas_item;

uniform sampler2D noise1;
uniform sampler2D noise2;
uniform sampler2D noise3;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
    float cosa = cos(rotation);
    float sina = sin(rotation);
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x 
    ) + pivot;
}

void fragment() {
	// Place fragment code here.
	COLOR = texture(noise1, fract(UV + TIME/200.0));
	
	vec4 texture2 = texture(noise2, 
						fract(
								rotateUV(
									UV + TIME/700.0,
									vec2(0.5),
									-TIME/800.0
								)
							)
						);
	vec4 texture3 = texture(noise3, 
						fract(
								rotateUV(
									// (UV + TIME/100.0)/2.0,
									UV,
									vec2(0.5),
									TIME/400.0
								) / ( 3.0 + cos(TIME/100.0) ) + vec2(0.22)
							)
						);
	COLOR.a = texture2.x * texture3.g;
	
	COLOR.r = COLOR.r*texture3.r;
	COLOR.g = COLOR.g*texture2.g;
	COLOR.b = COLOR.b*(1.0-texture3.b);
}
