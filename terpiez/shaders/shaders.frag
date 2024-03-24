#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;
// Inputs
uniform vec2 uResolution;
uniform float uTime;
// Outputs
out vec4 fragColor;
void main() {
    vec2 st = FlutterFragCoord().xy / uResolution;
    float denom = 1.0;
    float asset = (st.x - st.y) * uTime / denom;
    float redValue = abs(sin(asset));
    float red2 = abs(cos(asset));
    fragColor = vec4(red2, 0.0, redValue, 1.0);
}