#version 330

in highp vec4 var_position;
in mediump vec3 var_normal;
in mediump vec2 var_texcoord0;

uniform sampler2D shadow_depth_texture;

out vec4 fragColor;

float rgba_to_float(vec4 rgba)
{
    return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}

void main()
{

    float depthValue = texture(shadow_depth_texture, var_texcoord0.xy).r;
    fragColor = vec4(vec3(depthValue), 1.0);

    // vec4 color = texture(depth_texture, var_texcoord0.xy);
    // fragColor = vec4(vec3(rgba_to_float(color)), 1.0);
}
