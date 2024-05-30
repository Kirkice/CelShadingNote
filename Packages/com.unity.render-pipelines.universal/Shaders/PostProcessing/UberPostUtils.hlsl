#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

//  BWFlash
// float4 _DarkColor;
// float4 _LightColor;
// float2 _BW_Center;
// float _BW_Intensity;
// float _BW_Contrast;
// float _BW_Ratio;
// float _BW_Reversal;

// float2 UnityGradientNoiseDir(float2 p)
// {
//     p = fmod(p, 289);
//     float x = fmod((34 * p.x + 1) * p.x, 289) + p.y;
//     x = fmod((34 * x + 1) * x, 289);
//     x = frac(x / 41) * 2 - 1;
//     return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
// }
//
// float UnityGradientNoise(float2 UV, float Scale)
// {
//     float2 p = UV * Scale;
//     float2 ip = floor(p);
//     float2 fp = frac(p);
//     float d00 = dot(UnityGradientNoiseDir(ip), fp);
//     float d01 = dot(UnityGradientNoiseDir(ip + float2(0, 1)), fp - float2(0, 1));
//     float d10 = dot(UnityGradientNoiseDir(ip + float2(1, 0)), fp - float2(1, 0));
//     float d11 = dot(UnityGradientNoiseDir(ip + float2(1, 1)), fp - float2(1, 1));
//     fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
//     return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
// }
//
// float4 CalculateContrast(float contrastValue, float4 colorTarget)
// {
//     float t = 0.5 * (1.0 - contrastValue);
//     return mul(float4x4(contrastValue, 0, 0, t, 0, contrastValue, 0, t, 0, 0, contrastValue, t, 0, 0, 0, 1),
//                colorTarget);
// }
//
// float3 mod2D289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
// float2 mod2D289(float2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
// float3 permute(float3 x) { return mod2D289(((x * 34.0) + 1.0) * x); }
//
// float snoise(float2 v)
// {
//     const float4 C = float4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
//     float2 i = floor(v + dot(v, C.yy));
//     float2 x0 = v - i + dot(i, C.xx);
//     float2 i1;
//     i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
//     float4 x12 = x0.xyxy + C.xxzz;
//     x12.xy -= i1;
//     i = mod2D289(i);
//     float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0)) + i.x + float3(0.0, i1.x, 1.0));
//     float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
//     m = m * m;
//     m = m * m;
//     float3 x = 2.0 * frac(p * C.www) - 1.0;
//     float3 h = abs(x) - 0.5;
//     float3 ox = floor(x + 0.5);
//     float3 a0 = x - ox;
//     m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
//     float3 g;
//     g.x = a0.x * x0.x + h.x * x0.y;
//     g.yz = a0.yz * x12.xz + h.yz * x12.yw;
//     return 130.0 * dot(m, g);
// }
//
// float4 ApplyBWFlash(float2 TexC,Texture2D _MainTex, sampler sampler_MainTex)
// {
//     float2 CenteredUV = TexC.xy - float2(0.5, 0.5);
//     float2 lineUV =  float2(0, atan2(CenteredUV.x, CenteredUV.y) * (1.0 / TWO_PI) * 1.0);
//
//     float2 GradientNoise = float2(UnityGradientNoise(lineUV, 2000),
//                                   UnityGradientNoise(lineUV, 1000));
//
//
//     float2 texUV = TexC + (GradientNoise - float2(0.5, 0.5)) * 0.1;
//     float3 desaturateInitialColor = CalculateContrast(_BW_Contrast,
//                                                       SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, texUV)).rgb;
//     
//     float desaturateDot = dot(desaturateInitialColor, float3(0.299, 0.587, 0.114));
//     float3 desaturateVar = lerp(desaturateInitialColor, desaturateDot.xxx,
//                                 (1.0 + (0 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
//
//     float3 BlackWhite = step(desaturateVar, _BW_Ratio.xxx);
//
//     float2 appendResult23_g9 = float2((length(TexC - float2(0.5, 0.5)) * 0.0 * 2.0),
//                                       atan2((TexC - float2(0.5, 0.5)).x, (TexC - float2(0.5, 0.5)).y) * (1.0 / TWO_PI) * 1.0);
//
//     float simplePerlin2D = snoise(appendResult23_g9 * 100) * 0.5 + 0.5;
//
//     float simplePerlin2D28 = snoise(TexC * 100) * 0.5 + 0.5;
//
//     float lerpResult33 = lerp(simplePerlin2D, simplePerlin2D28, 0.5);
//     float LinePower41 = pow(lerpResult33, 0);
//     float lerpResult203 = lerp(LinePower41, 1.0, 0);
//     float lerpResult208 = lerp(1.0, LinePower41, 0);
//     float3 lerpResult44 = lerp((BlackWhite * lerpResult203), lerpResult208 * (1.0 - BlackWhite), _BW_Reversal);
//     float4 lerpResult52 = lerp(_DarkColor, _LightColor, float4(lerpResult44, 0.0));
//     float4 color = lerp(float4(desaturateVar, 0.0), lerpResult52, 0) ;
//     return _LightColor;
// }
