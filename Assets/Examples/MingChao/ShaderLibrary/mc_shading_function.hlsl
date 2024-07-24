#ifndef MC_FUNCTION_INCLUDED
#define MC_FUNCTION_INCLUDED
#include "mc_shader_input.hlsl"

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
inline float4 GetOutlinePosition(float3 positionVS, float3 N, half4 vertexColor)
{
    float z = positionVS.z;
    float width = GetOutlineWidth(z);// * vertexColor.a;

    half3 normalVS = TransformWorldToViewNormal(N);
    normalVS = SafeNormalize(half3(normalVS.xz, 0.0));

    positionVS += 0.1 * _OutlineZOffset * SafeNormalize(positionVS);
    positionVS += width * normalVS;

    float4 positionCS = TransformWViewToHClip(positionVS);
    positionCS.xy += _ScreenOffset.zw * positionCS.w;

    return positionCS;
}

//  获取描边颜色
inline half3 GetOutLineColor(half isBody, half skinmask)
{
    half3 color = (skinmask * _OutlineColor.rgb + (1 - skinmask) * _OutlineSkinColor.rgb) * isBody + _OutlineColor * (1 - isBody);
    return color;
}

#endif