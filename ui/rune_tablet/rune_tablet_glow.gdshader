shader_type canvas_item;

uniform vec3 glow_color: source_color = vec3(1,0,0);
uniform bool enable = false;
uniform bool full_glow = false;
uniform bool animate = true;
uniform float glow_velocity = 1.5;

const vec4 BLACK = vec4(0,0,0,1);
const vec4 WHITE = vec4(1,1,1,1);

bool isCloseToBlack(vec4 color) {
	return (distance(color,BLACK) <= 0.5);
}

vec3 glow(vec4 color){
	if(isCloseToBlack(color)){
		if(full_glow || !animate){
			return glow_color;
		} else if(animate) {
			return pow(sin(TIME*glow_velocity),2)*glow_color;
		}
	} else if(full_glow) {
		return WHITE.rgb;
	} else {
		return color.rgb;
	}
}


void fragment() {
	if(enable){
		COLOR.rgb = glow(COLOR);
	}
}



