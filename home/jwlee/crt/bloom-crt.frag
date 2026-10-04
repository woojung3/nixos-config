#version 300 es
precision highp float;
precision highp int;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

// A static, single-sample screen effect: no time uniform, blur or animation.
// The toggle owns redraw policy; curved sampling needs full-monitor damage.
void main() {
    vec2 p = v_texcoord * 2.0 - 1.0;
    const float curvature = 0.016;
    vec2 curved = p * (1.0 + curvature * p.yx * p.yx);
    vec2 uv = curved * 0.5 + 0.5;

    if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec4 source = texture(tex, uv);
    float luminance = dot(source.rgb, vec3(0.2126, 0.7152, 0.0722));
    float signal = clamp(luminance * 1.07 - 0.015, 0.0, 1.0);
    // Dark red-brown phosphor warms into orange, then pale gold at highlights.
    vec3 phosphor = mix(vec3(0.70, 0.22, 0.06), vec3(1.0, 0.43, 0.10),
                       smoothstep(0.03, 0.38, signal));
    phosphor = mix(phosphor, vec3(1.0, 0.79, 0.44),
                   smoothstep(0.65, 1.0, signal));

    // Preserve color identity while lending neutral tones a warm phosphor tint.
    const float sourceSaturation = 0.80;
    const float amberMix = 0.40;
    vec3 baseColor = mix(vec3(luminance), source.rgb, sourceSaturation);
    vec3 color = mix(baseColor, signal * phosphor, amberMix);

    // Alternating two-pixel dark/light bands; gentler on bright text.
    // Reuse luminance; no additional texture reads or time-dependent effects.
    float midtones = smoothstep(0.05, 0.35, signal)
                   * (1.0 - smoothstep(0.60, 0.98, signal));
    const float scanlineStrength = 2.0;
    const float scanlineBandHeight = 2.0;
    float lineContrast = scanlineStrength * (0.02 + 0.065 * midtones);
    float scanline = mix(0.99 - lineContrast, 0.99,
                         mod(floor(gl_FragCoord.y / scanlineBandHeight), 2.0));
    // Screen-fixed phosphor grain: an integer hash needs no extra texture or
    // trigonometry. Multiplicative noise preserves black and the existing hue.
    uvec2 pixel = uvec2(gl_FragCoord.xy);
    uint hash = pixel.x * 374761393u + pixel.y * 668265263u;
    hash = (hash ^ (hash >> 13u)) * 1274126177u;
    hash ^= hash >> 16u;
    float grain = float(hash & 65535u) / 65535.0 * 2.0 - 1.0;
    const float grainStrength = 0.025;
    float grainFactor = 1.0 + grain * grainStrength * (0.25 + 0.75 * midtones);

    float vignette = 1.0 - 0.13 * dot(p * p, p * p);
    fragColor = vec4(color * scanline * grainFactor * vignette, source.a);
}
