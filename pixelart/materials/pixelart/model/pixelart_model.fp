#version 140

in highp vec4 var_position;
in mediump vec3 var_normal;
in mediump vec2 var_texcoord0;
in mediump vec4 var_light;

uniform sampler2D tex0;

uniform fs_uniforms
{
    lowp vec4 tint;
    mediump vec4 diffuse_light;
};

// float sharpness = 1.0;

out vec4 fragColor;

/* float sharpen(float pix_coord)
{
    float norm = (fract(pix_coord) - 0.5) * 2.0;
    float norm2 = norm * norm;
    return floor(pix_coord) + norm * pow(norm2, sharpness) / 2.0 + 0.5;
}
 */
void main()
{

    /*
        // https://gist.github.com/Beefster09/7264303ee4b4b2086f372f1e70e8eddd
        // https://www.reddit.com/r/gamedev/comments/9k7xdo/fragment_shader_gist_for_smooth_pixel_scaling/
        vec2 vres = vec2(640, 360);
        vec4 color = texture(tex0, vec2(sharpen(var_texcoord0.x * vres.x) / vres.x, sharpen(var_texcoord0.y * vres.y) / vres.y)) * tint_pm;

        //  To visualize how this makes the grid:
        //   vec4 color = vec4(
        //       fract(sharpen(var_texcoord0.x * vres.x)),
        //       fract(sharpen(var_texcoord0.y * vres.y)),
        //        0.5, 1.0);
     */

    // Pre-multiply alpha since all runtime textures already are
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);

    vec4 color = texture(tex0, var_texcoord0.xy) * tint_pm;

    // Diffuse light calculations
    vec3 ambient_light = diffuse_light.xyz;
    vec3 diff_light = vec3(normalize(var_light.xyz - var_position.xyz));
    diff_light = max(dot(var_normal, diff_light), 0.0) + ambient_light;
    diff_light = clamp(diff_light, 0.0, 1.0);

    fragColor = vec4(color.rgb * diff_light, 1.0);
}
