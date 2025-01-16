#version 330

in mediump vec2 var_texcoord0;
in mediump vec4 var_resolution;

uniform sampler2D diffuse_texture;

out vec4 fragColor;

void main()
{
    vec2 iuv = (floor(var_resolution.xy * var_texcoord0.xy) + 0.5) * var_resolution.zw;
    vec4 texel = texture(diffuse_texture, iuv);
    fragColor = texel;
}
