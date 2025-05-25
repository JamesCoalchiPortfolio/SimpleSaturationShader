#version 330 compatibility

#include "settings.glsl"

// Input texture from the previous pass (the fully rendered scene)
uniform sampler2D colortex0;

// Texture coordinates from the vertex shader
varying vec2 texcoord;

// Standard luminance weights for converting RGB to grayscale
const vec3 LUMINANCE_VECTOR = vec3(0.299, 0.587, 0.114);

void main() {
    // Sample the original color from the screen texture
    vec4 originalColor = texture(colortex0, texcoord);

    // If alpha is 0 (fully transparent), skip processing to avoid artifacts
    if (originalColor.a == 0.0) {
        gl_FragColor = originalColor;
        return;
    }

    // --- Apply Saturation ---
    // Because the macro is in range 0-100
    // We need to normalize this for the saturation effect:
    // - value of 0.0 should mean 0.0 effect (grayscale).
    // - value of 50.0 should mean 1.0 effect (normal color).
    // - value of 100.0 should mean 2.0 effect (double saturation).
    float saturationEffectStrength = SATURATION / 50.0;

    // Calculate the brightness
    float luminance = dot(originalColor.rgb, LUMINANCE_VECTOR);

    // Creating a grayscale version
    vec3 grayscaleColor = vec3(luminance);

    // Linearly interpolate between grayscale and original color based on saturationEffectStrength
    // mix(x, y, a) is equivalent to x * (1.0 - a) + y * a
    vec3 saturatedColor = mix(grayscaleColor, originalColor.rgb, saturationEffectStrength);

    // Prevserve original alpha, output color
    gl_FragColor = vec4(saturatedColor, originalColor.a);
}