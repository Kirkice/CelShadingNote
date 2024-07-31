#ifndef MC_OUTLINE_PASS_INCLUDED
#define MC_OUTLINE_PASS_INCLUDED

#include "mc_shading_function.hlsl"
struct outline_data
{
    float4 vertex : POSITION;
    float2 texcoord0 : TEXCOORD0;
    float2 texcoord1 : TEXCOORD1;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float4 color : COLOR;
};

struct v2f_outline
{
    float4 PosH : SV_POSITION;
    float4 VColor : TEXCOORD1;
    float2 uv0 : TEXCOORD2;
};

v2f_outline VSOutline(outline_data v)
{
    v2f_outline o = (v2f_outline)0;
    float2 uv = v.texcoord1 * 2 - 1;
    float3 normal = float3(uv, sqrt(1 - dot(uv,uv)));
    
    float3 N = v.tangent;
    float4 positionCS = GetOutlinePosition(v.vertex, N);
    o.PosH = positionCS;
    o.VColor.rgb = N.xyz;
    o.VColor.a = v.color.x;
    o.uv0 = v.texcoord0;
    return o;
}

half4 PSSkinOutline(v2f_outline i) : COLOR
{
    return half4(_OutlineSkinColor.rgb, 1);
}

half4 PSOutline(v2f_outline i) : COLOR
{
    return half4(_OutlineColor.rgb, 1);
}

#endif