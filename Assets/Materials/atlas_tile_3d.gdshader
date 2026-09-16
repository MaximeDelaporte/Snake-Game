shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D atlas_texture : source_color;
uniform vec2 atlas_grid = vec2(6.0, 6.0);
uniform vec2 tile_index = vec2(0.0, 0.0);
uniform bool use_box_projection = false;
uniform bool use_mesh_uv = false;
uniform float tile_world_size = 1.0;

varying vec3 local_position;
varying vec3 local_normal;
varying vec2 mesh_uv;
varying vec3 scaled_local_position;

void vertex() {
	local_position = VERTEX;
	local_normal = normalize(NORMAL);
	mesh_uv = UV;
	scaled_local_position = VERTEX * vec3(
		length(MODEL_MATRIX[0].xyz),
		length(MODEL_MATRIX[1].xyz),
		length(MODEL_MATRIX[2].xyz)
	);
}

vec4 sample_cell(vec2 uv) {
	vec2 cell_size = 1.0 / atlas_grid;
	vec2 texel = 1.0 / vec2(textureSize(atlas_texture, 0));
	vec2 padding = texel;
	vec2 inner_min = tile_index * cell_size + padding;
	vec2 inner_size = cell_size - padding * 2.0;
	vec2 atlas_uv = inner_min + fract(uv) * inner_size;
	return texture(atlas_texture, atlas_uv);
}

vec4 sample_box_projection() {
	vec3 face_normal = normalize(cross(dFdx(scaled_local_position), dFdy(scaled_local_position)));
	vec3 n = abs(face_normal);
	if (n.y >= n.x && n.y >= n.z) {
		vec2 uv = face_normal.y >= 0.0
			? vec2(scaled_local_position.x, -scaled_local_position.z)
			: vec2(scaled_local_position.x, scaled_local_position.z);
		return sample_cell(uv / tile_world_size);
	}
	if (n.x >= n.z) {
		vec2 uv = face_normal.x >= 0.0
			? vec2(-scaled_local_position.z, scaled_local_position.y)
			: vec2(scaled_local_position.z, scaled_local_position.y);
		return sample_cell(uv / tile_world_size);
	}
	vec2 uv = face_normal.z >= 0.0
		? vec2(scaled_local_position.x, scaled_local_position.y)
		: vec2(-scaled_local_position.x, scaled_local_position.y);
	return sample_cell(uv / tile_world_size);
}

void fragment() {
	vec4 tex = use_box_projection
		? sample_box_projection()
		: (use_mesh_uv ? sample_cell(mesh_uv) : sample_cell(local_position.xz / tile_world_size));
	ALBEDO = tex.rgb;
}
