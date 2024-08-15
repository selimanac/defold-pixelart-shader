#version 330

in highp vec4 var_position;
in mediump vec3 var_normal;
in mediump vec2 var_texcoord0;
in mediump vec4 var_light;

uniform sampler2D tex0;

uniform fs_uniforms { lowp vec4 tint; };

out vec4 fragColor;

void main() {
  // Pre-multiply alpha since all runtime textures already are
  vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
  vec4 color = texture(tex0, var_texcoord0.xy) * tint_pm;

  // Diffuse light calculations
  vec3 ambient_light = vec3(0.5);
  vec3 diff_light = vec3(normalize(var_light.xyz - var_position.xyz));
  diff_light = max(dot(var_normal, diff_light), 0.0) + ambient_light;
  diff_light = clamp(diff_light, 0.0, 1.0);

  fragColor = vec4(color.rgb * diff_light, 1.0);
}
