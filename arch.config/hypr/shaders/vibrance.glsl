#version 320 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

void main() {
    vec4 color = texture(tex, v_texcoord);
    
    // --- SETTINGS ---
    
    // GAMMA: Controls the "weight" of the shadows.
    // 1.0 = Default (Flat)
    // 1.1 to 1.4 = Darker, richer shadows (Fixes "washed out" look)
    float gamma = 1.09; 
    
    // CONTRAST: Separates light from dark
    // 1.0 = Default
    // 1.1 = Slight boost
    float contrast = 1.0;
    
    // VIBRANCE: Keep the "pop" you already have
    float saturation_boost = 0.0;

    // --- LOGIC ---
    
    // 1. Apply Contrast
    color.rgb = (color.rgb - 0.5) * contrast + 0.5;

    // 2. Apply Saturation (Vibrance)
    float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 gray = vec3(luminance);
    color.rgb = mix(gray, color.rgb, 1.0 + saturation_boost);

    // 3. Apply Gamma (The fix for washed out grays)
    // We raise the color to the power of the gamma value.
    // Since colors are 0.0-1.0, a power > 1.0 makes midtones darker.
    color.rgb = pow(color.rgb, vec3(gamma));

    fragColor = color;
}
