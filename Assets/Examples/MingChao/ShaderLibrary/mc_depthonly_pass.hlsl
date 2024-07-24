#ifndef MC_DEPTH_ONLY_PASS_INCLUDE
#define MC_DEPTH_ONLY_PASS_INCLUDE

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// DEPTH ONLY
struct Attributes
{
    float4 position : POSITION;
    float2 texcoord : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 texcoord : TEXCOORD0;
    float4 positionOS : TEXCOORD2;
};

Varyings VSDepthOnly(Attributes input)
{
    Varyings output = (Varyings)0;

    output.positionOS = input.position;
    output.texcoord = input.texcoord;
    output.positionCS = TransformObjectToHClip(input.position.xyz);
    return output;
}

half4 PSDepthOnly(Varyings input) : SV_TARGET
{
    return 0;
}

#endif
