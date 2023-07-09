shader_type canvas_item;

// Color of the monochrome display
uniform vec4 color : source_color = vec4(0.89, 0.953, 0, 1.0);

// Background color
uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);

// How many shades we support
uniform float palette_size = 4.0;

// Each display pixel corresponds to how many real-world pixels?
uniform vec2 matrix_pixel_size = vec2(4.0, 4.0);

// How much of the edge should be left blank
uniform float border_scale = 0.02;

// This is used to sample from the screen behind us
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float calculate_brightness(vec4 c) {
	c = clamp(c, 0.0, 1.0);
    return 0.2126 * c.x + 0.7152 * c.g + 0.0722 * c.b;
}

void fragment() {
	// We now need to work backwards to find out what pixel on the
	// screen we should pull data from
	vec2 screen_pixels = floor(1.0 / SCREEN_PIXEL_SIZE);

	// This cuts up the main screen into the same size pixels as 
	// what we use on the display
	vec2 screen_pixel_dimensions = floor(screen_pixels / matrix_pixel_size);

	vec2 new_uv = floor(SCREEN_UV * screen_pixel_dimensions) / screen_pixel_dimensions;
	vec2 remainder_uv = fract(( SCREEN_UV - new_uv ) * screen_pixel_dimensions);

	// Get the underlying pixel value
	vec4 pixel_color = textureLod(screen_texture, new_uv, 0.0);
	
	// We're going to use brightness to go from RGB to grayscale
	float brightness = calculate_brightness(pixel_color);

	if (
		   remainder_uv.x < 0.4 
		|| remainder_uv.y < 0.4
		|| remainder_uv.y > 0.9
		|| remainder_uv.x > 0.9
	) {
		COLOR = background_color;
	}
	else if (
		   UV.x < border_scale
		|| UV.y < border_scale
		|| UV.y > (1.0 - border_scale)
		|| UV.x > (1.0 - border_scale)
	) {
		COLOR = background_color;
	}
	else if ( brightness < 0.2 ) {
		COLOR = color * 0.05;
		COLOR.a = 1.0;
	}
	else {
		brightness = floor(palette_size * brightness)/palette_size;
		COLOR = color * brightness;
		COLOR.a = 1.0;
	}
}
