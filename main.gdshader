shader_type spatial;
uniform sampler2D NOISE_PATTERN;
uniform vec4 color_in : source_color;
uniform float noise_scale;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float noiseValue = texture(NOISE_PATTERN, noise_scale*UV).x;
	ALBEDO = noiseValue*color_in.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
