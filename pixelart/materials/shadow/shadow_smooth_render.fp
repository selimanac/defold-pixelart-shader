#version 140

in highp vec4 var_position;
in highp vec4 var_position_world;

in mediump vec3 var_normal;
in mediump vec2 var_texcoord0;
in mediump vec4 var_texcoord0_shadow;

uniform sampler2D shadow_render_depth_texture;
uniform sampler2D shadow_render_diffuse_texture;

out vec4 fragColor;

vec2 rand(vec2 co)
{
    return vec2(fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453),
                fract(sin(dot(co.yx, vec2(12.9898, 78.233))) * 43758.5453)) *
           0.00047;
}

float rgba_to_float(vec4 rgba)
{
    return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}

float shadow_calculation(vec4 depth_data)
{
    // The 'depth_bias' value is per-scene dependant and must be tweaked
    // accordingly. It is needed to avoid shadow acne, which is basically a
    // precision issue.

    float depth_bias = 0.00002;
    float shadow = 0.0;
    float texel_size = 1.0 / 2048.0; // textureSize(tex1, 0);
    for (int x = -1; x <= 1; ++x)
    {
        for (int y = -1; y <= 1; ++y)
        {
            vec2 uv = depth_data.st + vec2(x, y) * texel_size;
            vec4 rgba = texture(shadow_render_depth_texture, uv + rand(uv));
            // vec4 rgba = texture2D(tex1, uv);
            float depth = rgba_to_float(rgba);
            // float depth = rgba.x;
            shadow += depth_data.z - depth_bias > depth ? 1.0 : 0.0;
        }
    }
    shadow /= 9.0;

    highp vec2 uv = depth_data.xy;
    if (uv.x < 0.0)
        shadow = 0.0;
    if (uv.x > 1.0)
        shadow = 0.0;
    if (uv.y < 0.0)
        shadow = 0.0;
    if (uv.y > 1.0)
        shadow = 0.0;

    return shadow;
}

void main()
{
    vec4 color = texture(shadow_render_diffuse_texture, var_texcoord0.xy);

    vec4 depth_proj = var_texcoord0_shadow / var_texcoord0_shadow.w;
    float shadow = shadow_calculation(depth_proj.xyzw);

    vec3 shadow_color1 = vec3(0.3, 0.3, 0.3);
    vec3 shadow_color = shadow_color1.xyz * shadow;
    fragColor = vec4(color.rgb * (1.0 - shadow_color), 1.0);
}
