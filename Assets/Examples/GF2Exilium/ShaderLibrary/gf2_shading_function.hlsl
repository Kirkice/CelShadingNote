#ifndef GF2_FUNCTION_INCLUDED
#define GF2_FUNCTION_INCLUDED
#include "gf2_lighting_function.hlsl"

inline float3 DecodeSmoothNormalTangentSpace(float2 uv2, float4 T, float3 N)
{
    float3 B = cross(N,T.xyz) * T.w;
    float3x3 TBN = float3x3(
        T.x,B.x,N.x,
        T.y,B.y,N.y,
        T.z,B.z,N.z
    );

    float2 uv = uv2 * 2 - 1;
    float3 normal = float3(uv, 1 - sqrt(1 - dot(uv,uv)));
    return mul(TBN, normal);
}

inline float3 DecodeSmoothNormalObjectSpace(float2 uv2)
{

    float2 uv = uv2 * 2 - 1;
    float3 normal = float3(uv, sqrt(1 - dot(uv,uv)));
    return normal;
}

//  获取描边宽度
inline float GetOutlineWidth(float positionVS_Z)
{
    float fovFactor = 2.414 / UNITY_MATRIX_P[1].y;
    float z = abs(positionVS_Z * fovFactor);

    float4 params = _OutlineWidthParams;
    float k = saturate((z - params.x) / (params.y - params.x));
    float width = lerp(params.z, params.w, k);

    return 0.01 * _OutlineWidth * width;
}

//  获取描边坐标
inline float4 GetOutlinePosition(float4 PosL, float3 N)
{
    float3 PosW = TransformObjectToWorld(PosL);
    float z = TransformWorldToView(float4(PosW,1)).z;
    float width = GetOutlineWidth(z);// * vertexColor.a;
    PosL.xyz = PosL.xyz + N * width;
    
    float3 PosV = TransformWorldToView(float4(TransformObjectToWorld(PosL),1));
    PosV += 0.1 * _OutlineZOffset * SafeNormalize(PosV);
    
    float4 positionCS = TransformWViewToHClip(PosV);
    positionCS.xy += _ScreenOffset.zw * positionCS.w;

    return positionCS;
}

//  获取描边颜色
inline half3 GetOutLineColor(half isBody, half skinmask)
{
    half3 color = (skinmask * _OutlineColor.rgb + (1 - skinmask) * _OutlineSkinColor.rgb) * isBody + _OutlineColor * (1 - isBody);
    return color;
}

//  获取纹理采样Color
inline void GetGF2TextureColor(half2 uv, out TextureData texData)
{
    texData.mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
    texData.msoColor = SAMPLE_TEXTURE2D(_MSOTexture, sampler_MSOTexture, uv);
    texData.bumpTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, uv), _NormalScale); 
}

inline void GetGF2PBRProperties(TextureData texData,out PBRData pbrData)
{
    pbrData.emission = 1 - texData.msoColor.a;
    pbrData.metallic = lerp(0, _Metallic, texData.msoColor.r);
    pbrData.smoothness = lerp(0, _Smoothness, texData.msoColor.g);
    pbrData.occlusion = lerp(1 - _Occlusion, 1, texData.msoColor.b);
    pbrData.directOcclusion = lerp(1 - _DirectOcclusion, 1, texData.msoColor.b);
    pbrData.albedo = texData.mainColor.rgb * _MainColor.rgb;
    pbrData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(pbrData.smoothness);
    pbrData.roughness = PerceptualRoughnessToRoughness(pbrData.perceptualRoughness);
}

inline half3 GetGF2Normal(half3 bumpTS,half3 T,half3 B, half3 N)
{
    float3x3 TBN = float3x3(T, B, N);
    float3 bumpWS = TransformTangentToWorld(bumpTS, TBN);
    return SafeNormalize(bumpWS);
}
#endif