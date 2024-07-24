#ifndef MC_INPUT_INCLUDED
#define MC_INPUT_INCLUDED
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

// 纹理
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);


uniform float4 _MainTex_ST;

CBUFFER_START(UnityPerMaterial)

//OutLine Setting
uniform half4 _OutlineColor;
uniform half4 _OutlineSkinColor;
uniform half _OutlineWidth;
uniform half4 _OutlineWidthParams;
uniform half _OutlineZOffset;
uniform half4 _ScreenOffset;

CBUFFER_END

#endif