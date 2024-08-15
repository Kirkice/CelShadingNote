#ifndef MC_INPUT_INCLUDED
#define MC_INPUT_INCLUDED
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NoiseCommon.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

// 纹理
TEXTURE2D(_Albedo0);
SAMPLER(sampler_Albedo0);
uniform float4 _Albedo0_ST;

TEXTURE2D(_NormalTex0);
SAMPLER(sampler_NormalTex0);
uniform float4 _NormalTex0_ST;

TEXTURE2D(_MsoTex0);
SAMPLER(sampler_MsoTex0);
uniform float4 _MsoTex0_ST;

TEXTURE2D(_Albedo1);
SAMPLER(sampler_Albedo1);
uniform float4 _Albedo1_ST;

TEXTURE2D(_NormalTex1);
SAMPLER(sampler_NormalTex1);
uniform float4 _NormalTex1_ST;

TEXTURE2D(_MsoTex1);
SAMPLER(sampler_MsoTex1);
uniform float4 _MsoTex1_ST;

TEXTURE2D(_Albedo2);
SAMPLER(sampler_Albedo2);
uniform float4 _Albedo2_ST;

TEXTURE2D(_NormalTex2);
SAMPLER(sampler_NormalTex2);
uniform float4 _NormalTex2_ST;

TEXTURE2D(_MsoTex2);
SAMPLER(sampler_MsoTex2);
uniform float4 _MsoTex2_ST;

CBUFFER_START(UnityPerMaterial)
uniform half _Metallic0;
uniform half _Subsurface0;
uniform half _Specular0;
uniform half _Roughness0;
uniform half _SpecularTint0;
uniform half _Anisotropic0;
uniform half _Sheen0;
uniform half _SheenTint0;
uniform half _ClearCoat0;
uniform half _ClearCoatGloss0;

uniform half _Metallic1;
uniform half _Subsurface1;
uniform half _Specular1;
uniform half _Roughness1;
uniform half _SpecularTint1;
uniform half _Anisotropic1;
uniform half _Sheen1;
uniform half _SheenTint1;
uniform half _ClearCoat1;
uniform half _ClearCoatGloss1;

uniform half _Metallic2;
uniform half _Subsurface2;
uniform half _Specular2;
uniform half _Roughness2;
uniform half _SpecularTint2;
uniform half _Anisotropic2;
uniform half _Sheen2;
uniform half _SheenTint2;
uniform half _ClearCoat2;
uniform half _ClearCoatGloss2;

uniform float _EdgeFactor; 
uniform float _InsideFactor;


uniform float _MaxHeight;
uniform float _TerrainPower;
uniform float _TerrainStrength;
uniform float4 _TerrainTillingOffset;
CBUFFER_END
#endif