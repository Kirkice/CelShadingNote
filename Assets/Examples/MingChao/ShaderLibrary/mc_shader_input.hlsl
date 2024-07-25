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

TEXTURE2D(_NormalTex);
SAMPLER(sampler_NormalTex);

uniform float4 _MainTex_ST;
uniform float4 _NormalTex_ST;

CBUFFER_START(UnityPerMaterial)

//  OutLine Setting
uniform half4 _OutlineColor;
uniform half4 _OutlineSkinColor;
uniform half _OutlineWidth;
uniform half4 _OutlineWidthParams;
uniform half _OutlineZOffset;
uniform half4 _ScreenOffset;

//  PBR Settings
uniform half _Metallic;
uniform half _Subsurface;
uniform half _Specular;
uniform half _Roughness;
uniform half _SpecularTint;
uniform half _Anisotropic;
uniform half _Sheen;
uniform half _SheenTint;
uniform half _ClearCoat;
uniform half _ClearCoatGloss;


CBUFFER_END

#endif