#version 330

in highp vec4 var_position;
in mediump vec3 var_normal;
in mediump vec2 var_texcoord0;
in mediump vec4 var_texcoord0_shadow;

uniform sampler2D shadow_render_depth_texture;
uniform sampler2D shadow_render_diffuse_texture;

out vec4 fragColor;

float rgba_to_float(vec4 rgba)
{
    return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}

float get_visibility(vec3 depth_data)
{
    float depth = rgba_to_float(texture(shadow_render_depth_texture, depth_data.st));

    const float depth_bias = 0.00002;

    // The 'depth_bias' value is per-scene dependant and must be tweaked
    // accordingly. It is needed to avoid shadow acne, which is basically a
    // precision issue.
    if (depth < depth_data.z - depth_bias)
    {
        return 0.7; // Shadow Alpha amount
    }

    return 1.0;
}

void main()
{
    vec4 color = texture(shadow_render_diffuse_texture, var_texcoord0.xy);

    // Note: We need to divide the projected coordinate by the w component to move
    // it from clip space into a UV coordinate that we can use to sample the depth
    // map from. When we set the gl_Position in the vertex shader, this is done
    // automatically for us by the hardware but since we are just passing the
    // multiplied value along as a varying we have to do it ourselves. Just google
    // perspective division by w or something similar and you'll find better
    // resources that explains the reasoning. Also note that this is only really
    // needed for perspective projections.
    vec4 depth_proj = var_texcoord0_shadow / var_texcoord0_shadow.w;

    fragColor = vec4(color.rgb * get_visibility(depth_proj.xyz), 1.0);
}
