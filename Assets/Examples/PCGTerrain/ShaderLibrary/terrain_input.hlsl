#ifndef MC_INPUT_INCLUDED
#define MC_INPUT_INCLUDED
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/NoiseCommon.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

// 纹理
TEXTURECUBE(_SkyboxCube);
SAMPLER(sampler_SkyboxCube);

TEXTURE2D(_AlbedoTex0);
SAMPLER(sampler_AlbedoTex0);
uniform float4 _AlbedoTex0_ST;

TEXTURE2D(_NormalTex0);
SAMPLER(sampler_NormalTex0);

TEXTURE2D(_TangentTex0);
SAMPLER(sampler_TangentTex0);

TEXTURE2D(_RoughnessTex0);
SAMPLER(sampler_RoughnessTex0);




TEXTURE2D(_AlbedoTex1);
SAMPLER(sampler_AlbedoTex1);
uniform float4 _AlbedoTex1_ST;

TEXTURE2D(_NormalTex1);
SAMPLER(sampler_NormalTex1);

TEXTURE2D(_TangentTex1);
SAMPLER(sampler_TangentTex1);

TEXTURE2D(_RoughnessTex1);
SAMPLER(sampler_RoughnessTex1);




TEXTURE2D(_AlbedoTex2);
SAMPLER(sampler_AlbedoTex2);
uniform float4 _AlbedoTex2_ST;

TEXTURE2D(_NormalTex2);
SAMPLER(sampler_NormalTex2);

TEXTURE2D(_TangentTex2);
SAMPLER(sampler_TangentTex2);

TEXTURE2D(_RoughnessTex2);
SAMPLER(sampler_RoughnessTex2);

CBUFFER_START(UnityPerMaterial)

uniform float3 _BaseColor0;
uniform float _NormalStrength0;
uniform float _Roughness0;
uniform float _Metallic0;
uniform float _Subsurface0;
uniform float _Specular0;
uniform float _SpecularTint0;
uniform float _Anisotropic0;
uniform float _Sheen0;
uniform float _SheenTint0;
uniform float _ClearCoat0;
uniform float _ClearCoatGloss0;
uniform float _RoughnessMapMod0;
uniform float _IndirectF0_0;
uniform float _IndirectF90_0;

uniform float3 _BaseColor1;
uniform float _NormalStrength1;
uniform float _Roughness1;
uniform float _Metallic1;
uniform float _Subsurface1;
uniform float _Specular1;
uniform float _SpecularTint1;
uniform float _Anisotropic1;
uniform float _Sheen1;
uniform float _SheenTint1;
uniform float _ClearCoat1;
uniform float _ClearCoatGloss1;
uniform float _RoughnessMapMod1;
uniform float _IndirectF0_1;
uniform float _IndirectF90_1;

uniform float3 _BaseColor2;
uniform float _NormalStrength2;
uniform float _Roughness2;
uniform float _Metallic2;
uniform float _Subsurface2;
uniform float _Specular2;
uniform float _SpecularTint2;
uniform float _Anisotropic2;
uniform float _Sheen2;
uniform float _SheenTint2;
uniform float _ClearCoat2;
uniform float _ClearCoatGloss2;
uniform float _RoughnessMapMod2;
uniform float _IndirectF0_2;
uniform float _IndirectF90_2;

uniform float _EdgeFactor; 
uniform float _InsideFactor;

uniform float _MaxHeight;
uniform float _TerrainPower;
uniform float _TerrainStrength;
uniform float4 _TerrainTillingOffset;
CBUFFER_END
#endif