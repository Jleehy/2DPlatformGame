shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 dawn_color : source_color = vec4(0.86, 0.70, 0.70, 1.0);
uniform vec4 day_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 dusk_color : source_color = vec4(0.59, 0.66, 0.78, 1.0);
uniform vec4 night_color : source_color = vec4(0.07, 0.09, 0.38, 1.0);

uniform float brightness : hint_range(0.0, 10.0) = 1.0;
uniform float contrast : hint_range(0.0, 10.0) = 1.0;
uniform float saturation : hint_range(0.0, 10.0) = 1.0;
uniform float pop_strength : hint_range(0.0, 10.0) = 1.0;
uniform float pop_threshold : hint_range(0.0, 10.0) = 1.0;

// Light scattering parameters
uniform float scatter_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float scatter_spread : hint_range(0.1, 10.0) = 2.0;
uniform int scatter_samples : hint_range(1, 16) = 8;
uniform vec2 light_direction = vec2(1.0, -1.0); // Light direction for scattering

uniform bool overlay = false;

void fragment() {
    vec3 cycle_color = night_color.rgb;
    
    // Base color from screen texture
    vec3 base_col = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
    vec3 out_col = base_col;
    
    // Calculate luminance
    float grey = dot(base_col, vec3(0.299, 0.587, 0.114));
    
    // Overlay mode blending
    if (overlay) {
        if (grey > 0.5) {
            out_col = 1.0 - (1.0 - 2.0 * (base_col - 0.5)) * (1.0 * cycle_color.rgb);
        } else {
            out_col = 2.0 * base_col * cycle_color.rgb;
        }
    }
    
    // Apply color adjustments
    out_col = mix(vec3(grey), out_col, saturation);
    out_col = (out_col - 0.5) * contrast + 0.5;
    out_col = out_col + pop_strength * max(grey - pop_threshold, 0.0);
    out_col = out_col * brightness;
    
    // Light scattering effect
    if (AT_LIGHT_PASS) {
        vec3 lights_col = texture(TEXTURE, UV).rgb;
        float light_value = length(lights_col);
        
        // Light scattering calculation
        if (light_value > 0.1) {
            vec2 scatter_dir = normalize(light_direction) * scatter_spread / float(scatter_samples);
            vec2 scatter_uv = UV - scatter_dir * float(scatter_samples) * 0.5;
            
            vec3 scatter_col = vec3(0.0);
            float scatter_weight = 0.0;
            
            for (int i = 0; i < scatter_samples; i++) {
                float weight = 1.0 - abs(float(i) / float(scatter_samples) - 0.5) * 2.0;
                scatter_col += texture(TEXTURE, scatter_uv).rgb * weight;
                scatter_weight += weight;
                scatter_uv += scatter_dir;
            }
            
            scatter_col /= scatter_weight;
            out_col = mix(out_col, scatter_col, scatter_intensity * light_value);
        }
        
        // Original light processing
        grey = dot(lights_col, vec3(0.333));
        out_col = mix(out_col, base_col * normalize(lights_col + 0.05) * 3.0, grey);
        out_col += 0.1 * lights_col;
        
        COLOR = vec4(out_col * cycle_color.rgb, 1.0);
    } else {
        COLOR = vec4(out_col * cycle_color.rgb, 1.0);
    }
}