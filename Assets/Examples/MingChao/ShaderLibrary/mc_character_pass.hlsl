#ifndef MC_CHARACTER_PASS_INCLUDED
#define MC_CHARACTER_PASS_INCLUDED
#include "mc_shading_function.hlsl"

//  Body Pass
struct VertexIn_Body
{
    float4 PosL : POSITION;
    float2 TexC : TEXCOORD0;
    // float3 NormalL : NORMAL;
    // float4 COLOR : COLOR;
};

struct VertexOut_Body
{
    float4 PosH : SV_POSITION;
    float4 TexC : TEXCOORD0;
    // float3 NormalW : TEXCOORD0;
    // float3 PosW : TEXCOORD2;
    // float4 PosS : TEXCOORD3;
    // float4 COLOR : TEXCOORD4;
    // float4 TargetPosSS : TEXCOORD5;
};

VertexOut_Body VSBody(VertexIn_Body vin)
{
    VertexOut_Body vout = (VertexOut_Body)0;
    vout.PosH = TransformObjectToHClip(vin.PosL);
    vout.TexC.xy = vin.TexC;
    return vout;
}

half4 PSBody(VertexOut_Body pin) : SV_Target
{
    return _MainTex.Sample(sampler_MainTex,pin.TexC);
}

//  Shadow Pass
struct VertexIn_Shadow
{
    float4 PosL : POSITION;
    float3 NormalL : NORMAL;
    float2 TexC : TEXCOORD0;
};

struct VertexOut_Shadow
{
    float2 TexC : TEXCOORD0;
    float4 PosH : SV_POSITION;
};

float4 GetShadowPositionHClip(VertexIn_Shadow input)
{
    float3 positionWS = TransformObjectToWorld(input.PosL.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.NormalL);

    Light mainLight = GetMainLight();
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, mainLight.direction));

    #if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    return positionCS;
}

VertexOut_Shadow VSShadow(VertexIn_Shadow input)
{
    VertexOut_Shadow output;
    output.TexC = input.TexC;
    output.PosH = GetShadowPositionHClip(input);
    return output;
}

half4 PSShadow(VertexOut_Shadow input) : SV_TARGET
{
    return 0;
}

#endif