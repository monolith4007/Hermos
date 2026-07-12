//
// Swaps Sonic's palette with Knuckles'. Hard-coded to 15 colors, which is the number of colors on their palettes.
// Taken from this tutorial by DragoniteSpam: https://youtu.be/bK5Nhh18GkU?si=_bZDKj2d1Ev1An1p
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samp_targets;

void main()
{
	vec4 sampled = texture2D(gm_BaseTexture, v_vTexcoord);
	
	for (float i = 0.0; i < 15.0; i += 1.0)
	{
		vec3 target = texture2D(samp_targets, vec2(i / 15.0, 0.0)).rgb;
		if (distance(target, sampled.rgb) < 0.025140) // Sonic's palette for his sprinting sprite isn't identical to his other sprites, hence this weird threshold
		{
			sampled.rgb = texture2D(samp_targets, vec2(i / 15.0, 0.5)).rgb;
		}
	}
	
    gl_FragColor = sampled * v_vColour;
}