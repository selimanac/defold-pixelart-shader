#version 140

in highp vec4 var_position;
in mediump vec3 var_normal;
in mediump vec2 var_texcoord0;
in mediump vec4 var_texcoord0_shadow;
in mediump vec4 var_light;

uniform sampler2D shadow_render_depth_texture;
uniform sampler2D shadow_render_diffuse_texture;

uniform fs_uniforms
{
    lowp vec4 diffuse_light;
    lowp vec4 bias;
    lowp vec4 shadow_opacity;
};

out vec4 fragColor;

float rgba_to_float(vec4 rgba)
{
    return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}

float get_visibility(vec3 depth_data)
{
    float depth = rgba_to_float(texture(shadow_render_depth_texture, depth_data.st));

    float depth_bias = bias.x;

    // The 'depth_bias' value is per-scene dependant and must be tweaked
    // accordingly. It is needed to avoid shadow acne, which is basically a
    // precision issue.
    if (depth < depth_data.z - depth_bias)
    {
        return 1.0 - shadow_opacity.x; // Shadow Alpha amount
    }

    return 1.0;
}

void main()
{
    vec4 color = texture(shadow_render_diffuse_texture, var_texcoord0.xy);

    // Diffuse light calculations.
    vec3 ambient_light = diffuse_light.xyz;
    vec3 diff_light = vec3(normalize(var_light.xyz - var_position.xyz));
    diff_light = max(dot(var_normal, diff_light), 0.0) + ambient_light;
    diff_light = clamp(diff_light, 0.0, 1.0);

    // Note: We need to divide the projected coordinate by the w component to move
    // it from clip space into a UV coordinate that we can use to sample the depth
    // map from. When we set the gl_Position in the vertex shader, this is done
    // automatically for us by the hardware but since we are just passing the
    // multiplied value along as a varying we have to do it ourselves. Just google
    // perspective division by w or something similar and you'll find better
    // resources that explains the reasoning. Also note that this is only really
    // needed for perspective projections.
    vec4 depth_proj = var_texcoord0_shadow / var_texcoord0_shadow.w;

    fragColor = vec4(color.rgb * diff_light * get_visibility(depth_proj.xyz), 1.0);
}
