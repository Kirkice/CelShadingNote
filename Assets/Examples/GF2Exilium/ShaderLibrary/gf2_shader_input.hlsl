#ifndef GF2_INPUT_INCLUDED
#define GF2_INPUT_INCLUDED
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

TEXTURE2D(_MSOTexture);
SAMPLER(sampler_MSOTexture);

TEXTURE2D(_RampTexture);
SAMPLER(sampler_RampTexture);

uniform float4 _MainTex_ST;
uniform float4 _NormalTex_ST;
uniform float4 _MSOTexture_ST;
uniform float4 _RampTexture_ST;

CBUFFER_START(UnityPerMaterial)

//  OutLine Setting
uniform half4 _OutlineColor;
uniform half4 _OutlineSkinColor;
uniform half _OutlineWidth;
uniform half4 _OutlineWidthParams;
uniform half _OutlineZOffset;
uniform half4 _ScreenOffset;

//  PBR Settings
uniform half4 _MainColor;
uniform half _NormalScale;
uniform half _Metallic;
uniform half _Smoothness;
uniform half _Occlusion;

// Direct Light
uniform half4 _SelfLight;
uniform half _MainLightColorLerp;
uniform half _DirectOcclusion;

// Shadow
uniform float4 _ShadowColor;
uniform float _ShadowOffset;
uniform float _ShadowSmoothNdotL;
uniform float _ShadowSmoothScene;
uniform float _ShadowStrength;

// Indirect
uniform float4 _SelfEnvColor;
uniform float _EnvColorLerp;
uniform float _IndirDiffUpDirSH;
uniform float _IndirDiffIntensity;
uniform float _IndirSpecCubeWeight;
uniform float _IndirSpecIntensity;

// Emission
uniform float4 _EmissionCol;

// RimLight
uniform float4 _DirectRimFrontCol;
uniform float4  _DirectRimBackCol;
uniform float _DirectRimWidth;
uniform float _PunctualRimWidth;

CBUFFER_END

#endif