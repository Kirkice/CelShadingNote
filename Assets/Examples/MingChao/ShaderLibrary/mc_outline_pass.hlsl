#ifndef MC_OUTLINE_PASS_INCLUDED
#define MC_OUTLINE_PASS_INCLUDED

#include "mc_shading_function.hlsl"
struct outline_data
{
    float4 vertex : POSITION;
    float2 texcoord0 : TEXCOORD0;
    float3 normal : NORMAL;
    float3 tangent : TANGENT;
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
    float3 PosW = TransformObjectToWorld(v.vertex);
    float3 N = TransformObjectToWorld(v.normal);
    float4 positionCS = GetOutlinePosition(TransformWorldToView(PosW), N, v.color);
    o.PosH = positionCS;
    o.VColor = v.color;
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