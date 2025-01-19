#version 140
in mediump vec2 var_texcoord0;

out vec4 color_out;

uniform lowp sampler2D tex0;

void main()
{
    color_out = texture(tex0, var_texcoord0.xy);
}
