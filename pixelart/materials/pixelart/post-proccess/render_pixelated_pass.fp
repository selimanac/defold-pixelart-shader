#version 140

in mediump vec2 var_texcoord0;
in mediump vec4 var_resolution;

out vec4 color_out;

uniform sampler2D diffuse_texture;
uniform sampler2D normal_texture;
uniform sampler2D depth_texture;

uniform fs_uniforms
{
    mediump vec4 normal_edge_coefficient;
    mediump vec4 depth_edge_coefficient;
};

float getDepth(int x, int y)
{
    return texture(depth_texture, var_texcoord0.xy + vec2(x, y) * var_resolution.zw).r;
}

vec3 getNormal(int x, int y)
{
    return texture(normal_texture, var_texcoord0.xy + vec2(x, y) * var_resolution.zw).rgb * 2.0 - 1.0;
}

float neighborNormalEdgeIndicator(int x, int y, float depth, vec3 normal)
{
    float depthDiff = getDepth(x, y) - depth;

    // Edge pixels should yield to faces closer to the bias direction.
    vec3 normalEdgeBias = vec3(1., 1., 1.); // This should probably be a parameter.
    float normalDiff = dot(normal - getNormal(x, y), normalEdgeBias);
    float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);

    // Only the shallower pixel should detect the normal edge.
    float depthIndicator = clamp(sign(depthDiff * .25 + .0025), 0.0, 1.0);

    return distance(normal, getNormal(x, y)) * depthIndicator * normalIndicator;
}

float depthEdgeIndicator()
{
    float depth = getDepth(0, 0);
    vec3 normal = getNormal(0, 0);
    float diff = 0.0;
    diff += clamp(getDepth(1, 0) - depth, 0.0, 1.0);
    diff += clamp(getDepth(-1, 0) - depth, 0.0, 1.0);
    diff += clamp(getDepth(0, 1) - depth, 0.0, 1.0);
    diff += clamp(getDepth(0, -1) - depth, 0.0, 1.0);
    return floor(smoothstep(0.01, 0.02, diff) * 2.) / 2.;
}

float normalEdgeIndicator()
{
    float depth = getDepth(0, 0);
    vec3 normal = getNormal(0, 0);
    float indicator = 0.0;

    indicator += neighborNormalEdgeIndicator(0, -1, depth, normal);
    indicator += neighborNormalEdgeIndicator(0, 1, depth, normal);
    indicator += neighborNormalEdgeIndicator(-1, 0, depth, normal);
    indicator += neighborNormalEdgeIndicator(1, 0, depth, normal);

    return step(0.1, indicator);
}

/*
float lum(vec4 color)
{
    vec4 weights = vec4(.2126, .7152, .0722, .0);
    return dot(color, weights);
}

float smoothSign(float x, float radius)
{
    return smoothstep(-radius, radius, x) * 2.0 - 1.0;
}

float rgba_to_float(vec4 rgba)
{
    return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}
 */

void main()
{
    vec4 texel = texture(diffuse_texture, var_texcoord0.xy);

    float normalEdgeCoefficient = normal_edge_coefficient.x; // 0.0 - 2.0
    float depthEdgeCoefficient = depth_edge_coefficient.x;   // 0.0 - 1.0

    /*
        // surface
        float tLum = lum(texel);
        float normalEdgeCoefficient = (smoothSign(tLum - .3, .1) + .7) * .25;
        float depthEdgeCoefficient = (smoothSign(tLum - .3, .1) + .7) * .3;
     */

    float dei = depthEdgeIndicator();
    float nei = normalEdgeIndicator();

    float coefficient = dei > 0.0 ? (1.0 - depthEdgeCoefficient * dei) : (1.0 + normalEdgeCoefficient * nei);

    color_out = texel * coefficient;
}
