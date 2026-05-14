shader_type canvas_item;

// flat = no interpolar entre vértices, valor exacto del sprite
varying flat vec4 modulate;

uniform vec2 texture_size = vec2(64.0, 64.0); 

void vertex() {
    modulate = COLOR;
}

void fragment() {
    vec2 pixel_uv = UV * texture_size;

    vec2 seam = floor(pixel_uv + 0.5);
    vec2 dudv  = fwidth(pixel_uv);

    vec2 snapped = (seam + clamp(
        (pixel_uv - seam) / dudv,
        vec2(-0.5),
        vec2( 0.5)
    )) / texture_size;

    vec4 tex_color = texture(TEXTURE, snapped);

    // igual que en el video: rgb * modulate.rgb, alpha * modulate.a
    COLOR = vec4(tex_color.rgb * modulate.rgb, tex_color.a * modulate.a);
}