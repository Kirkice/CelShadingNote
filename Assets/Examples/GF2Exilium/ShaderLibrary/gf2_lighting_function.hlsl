#ifndef GF2_LIGHTING_INCLUDED
#define GF2_LIGHTING_INCLUDED
#include "gf2_shader_input.hlsl"

#define FGDTEXTURE_RESOLUTION (64)

struct DirectLighting
{
    float3 diffuse;
    float3 specular;
    float3 rimColor;
};

struct IndirectLighting
{
    float3 diffuse;
    float3 specular;
};

struct PBRData
{
    float emission;
    float metallic;
    float smoothness;
    float occlusion;
    float directOcclusion;
    float perceptualRoughness;
    float roughness;
    float3 albedo;
};

struct TextureData
{
    float4 mainColor;
    float4 msoColor;
    float3 bumpTS;
};

TEXTURE2D(_PreIntegratedFGD_GGXDisneyDiffuse);
TEXTURE2D(_PreIntegratedFGD_CharlieAndFabric);

// For image based lighting, a part of the BSDF is pre-integrated.
// This is done both for specular GGX height-correlated and DisneyDiffuse
// reflectivity is  Integral{(BSDF_GGX / F) - use for multiscattering
void GetPreIntegratedFGDGGXAndDisneyDiffuse(float NdotV, float perceptualRoughness, float3 fresnel0,
                                            out float3 specularFGD, out float diffuseFGD, out float reflectivity)
{
    // We want the LUT to contain the entire [0, 1] range, without losing half a texel at each side.
    float2 coordLUT = Remap01ToHalfTexelCoord(float2(sqrt(NdotV), perceptualRoughness), FGDTEXTURE_RESOLUTION);

    float3 preFGD = SAMPLE_TEXTURE2D_LOD(_PreIntegratedFGD_GGXDisneyDiffuse, sampler_LinearClamp, coordLUT, 0).xyz;

    // Pre-integrate GGX FGD
    // Integral{BSDF * <N,L> dw} =
    // Integral{(F0 + (1 - F0) * (1 - <V,H>)^5) * (BSDF / F) * <N,L> dw} =
    // (1 - F0) * Integral{(1 - <V,H>)^5 * (BSDF / F) * <N,L> dw} + F0 * Integral{(BSDF / F) * <N,L> dw}=
    // (1 - F0) * x + F0 * y = lerp(x, y, F0)
    specularFGD = lerp(preFGD.xxx, preFGD.yyy, fresnel0);

    // Pre integrate DisneyDiffuse FGD:
    // z = DisneyDiffuse
    // Remap from the [0, 1] to the [0.5, 1.5] range.
    diffuseFGD = preFGD.z + 0.5;

    reflectivity = preFGD.y;
}

void GetPreIntegratedFGDGGXAndLambert(float NdotV, float perceptualRoughness, float3 fresnel0, out float3 specularFGD,
                                      out float diffuseFGD, out float reflectivity)
{
    GetPreIntegratedFGDGGXAndDisneyDiffuse(NdotV, perceptualRoughness, fresnel0, specularFGD, diffuseFGD, reflectivity);
    diffuseFGD = 1.0;
}

void GetPreIntegratedFGDCharlieAndFabricLambert(float NdotV, float perceptualRoughness, float3 fresnel0,
                                                out float3 specularFGD, out float diffuseFGD, out float reflectivity)
{
    // Read the texture
    float3 preFGD = SAMPLE_TEXTURE2D_LOD(_PreIntegratedFGD_CharlieAndFabric, sampler_LinearClamp,
                                         float2(NdotV, perceptualRoughness), 0).xyz;

    specularFGD = lerp(preFGD.xxx, preFGD.yyy, fresnel0) * 2.0f * PI;

    // z = FabricLambert
    diffuseFGD = preFGD.z;

    reflectivity = preFGD.y;
}

float GetCharacterDirectRimLightArea(float3 normalVS, float2 screenUV, float d, float rimWidth)
{
    // RimLight
    float normalExtendLeftOffset = normalVS.x > 0 ? 1.0 : -1.0;
    normalExtendLeftOffset *= rimWidth * 0.0044;

    float eyeDepth = LinearEyeDepth(d, _ZBufferParams);

    float2 extendUV = screenUV;
    extendUV.x += normalExtendLeftOffset / (eyeDepth + 3.0);

    float extendedRawDepth = SAMPLE_TEXTURE2D_X_LOD(_CameraDepthTexture, sampler_LinearClamp, extendUV, 0).x;
    float extendedEyeDepth = LinearEyeDepth(extendedRawDepth, _ZBufferParams);

    float depthOffset = extendedEyeDepth - eyeDepth;

    float rimArea = saturate(depthOffset * 4);

    return rimArea;
}

inline void GF2LightingPhysicallyBased(PBRData pbrData, Light light)
{
    // dirLight.lightColor = lerp(dirLight.lightColor, _SelfLight.rgb, _MainLightColorLerp);
    //
    // float3 lightDirWS = dirLight.lightDirection;
    // float NdotL = dot(normalWS, lightDirWS);
    //
    // float clampedNdotL = saturate(NdotL);
    // float halfLambert = NdotL * 0.5 + 0.5;
    // float clampedRoughness = max(roughness, dirLight.minRoughness);
    //
    // float LdotV, NdotH, LdotH, invLenLV;
    // GetBSDFAngle(viewDirWS, lightDirWS, NdotL, NdotV, LdotV, NdotH, LdotH, invLenLV);
    // float3 lightDirVS = TransformWorldToViewDir(lightDirWS);
    // lightDirVS = SafeNormalize(lightDirVS);
    //
    // // Shadow
    // // Remap Shadow area for NPR diffuse, but we should use clampedNdotL for PBR specular.
    // float shadowAttenuation = 1;
    // if (lightIndex == 0)
    // {
    //     // Apply Shadows
    //     // TODO: add different direct light shadowmap
    //     shadowAttenuation = SAMPLE_TEXTURE2D(_ScreenSpaceShadowmapTexture, sampler_PointClamp, screenUV).x;
    //     #ifdef _PEROBJECT_SCREEN_SPACE_SHADOW
    //                         shadowAttenuation = min(shadowAttenuation, SamplePerObjectScreenSpaceShadowmap(screenUV));
    //     #endif
    // }
    //
    // float shadowNdotL = SigmoidSharp(halfLambert, _ShadowOffset, _ShadowSmoothNdotL * 5);
    // float shadowScene = SigmoidSharp(shadowAttenuation, 0.5, _ShadowSmoothScene * 5);
    // float shadowArea = min(shadowNdotL, shadowScene);
    // shadowArea = lerp(1, shadowArea, _ShadowStrength);
    //
    // float3 shadowRamp = lerp(_ShadowColor.rgb, float3(1, 1, 1), shadowArea);
    // #ifdef _SHADOW_RAMP
    //                     shadowRamp = SampleDirectShadowRamp(TEXTURE2D_ARGS(_ShadowRampTex, sampler_ShadowRampTex), shadowArea).xyz;
    // #endif
    //
    // // BRDF
    // float3 F = F_Schlick(fresnel0, LdotH);
    // float DV = DV_SmithJointGGX(NdotH, abs(NdotL), clampedNdotV, clampedRoughness);
    // float3 specTerm = F * DV;
    // float diffTerm = Lambert();
    //
    // #ifdef _SHADOW_RAMP
    //                     float specRange = saturate(DV);
    //                     float3 specRampCol = SampleDirectSpecularRamp(TEXTURE2D_ARGS(_ShadowRampTex, sampler_ShadowRampTex), specRange).xyz;
    //                     specTerm = F * clamp(specRampCol.rgb + DV, 0, 10);
    // #endif
    //
    // // Direct Rim Light
    // float3 frontRimCol = lerp(_DirectRimFrontCol.rgb, _DirectRimFrontCol.rgb * dirLight.lightColor,
    //                           _DirectRimFrontCol.a);
    // float3 backRimCol = lerp(_DirectRimBackCol.rgb, _DirectRimBackCol.rgb * dirLight.lightColor, _DirectRimBackCol.a);
    // float3 directRim = GetRimColor(directRimArea, diffuseColor, normalVS, lightDirVS, shadowArea, frontRimCol,
    //                                backRimCol);
    //
    // // Accumulate
    // directLighting.diffuse += diffuseColor * diffTerm * shadowRamp * dirLight.lightColor * directOcclusion;
    // directLighting.specular += specTerm * clampedNdotL * shadowScene * dirLight.lightColor * directOcclusion;
    // rimColor += directRim;
}

inline void GetGF2DirectLighting(half3 N, half depth, half2 screenUV, PBRData pbrData)
{
    uint meshRenderingLayers = GetMeshRenderingLayer();

    float3 normalVS = TransformWorldToViewNormal(N);
    normalVS = SafeNormalize(normalVS);

    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(N);
    float NdotV = dot(N, viewDirWS);
    float clampedNdotV = ClampNdotV(NdotV);

    DirectLighting directLighting;
    IndirectLighting indirectLighting;
    ZERO_INITIALIZE(DirectLighting, directLighting);
    ZERO_INITIALIZE(IndirectLighting, indirectLighting);

    float3 diffuseColor = ComputeDiffuseColor(pbrData.albedo, pbrData.metallic);
    float3 fresnel0 = ComputeFresnel0(pbrData.albedo, pbrData.metallic, DEFAULT_SPECULAR_VALUE);

    float3 specularFGD;
    float diffuseFGD;
    float reflectivity;

    GetPreIntegratedFGDGGXAndDisneyDiffuse(clampedNdotV, pbrData.perceptualRoughness, fresnel0, specularFGD, diffuseFGD,
                                           reflectivity);
    float energyCompensation = 1.0 / reflectivity - 1.0;

    float directRimArea = GetCharacterDirectRimLightArea(normalVS, screenUV, depth, _DirectRimWidth);
}
#endif
