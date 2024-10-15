#ifndef CHARACTER_MAIN_PASS_INCLUDED
#define CHARACTER_MAIN_PASS_INCLUDED
#include "character_shading_function.hlsl"

struct VertexIn_Body
{
    float4 PosL     : POSITION;
    float2 TexC     : TEXCOORD0;
    float3 NormalL  : NORMAL;
    float4 TangentL : TANGENT;
    float4 Color    : COLOR;
    float2 uv1      : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID 
};

struct VertexOut_Body
{
    float4 PosH         : SV_POSITION;
    float4 TexC         : TEXCOORD0;
    float3 NormalW      : TEXCOORD1;
    float3 TangentW     : TEXCOORD2;
    float3 BitangentW   : TEXCOORD3;
    float3 PosW         : TEXCOORD4;
    float2 screenUV     : TEXCOORD5;
    float4 Color        : TEXCOORD6;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

VertexOut_Body VSBody(VertexIn_Body vin)
{
    VertexOut_Body vout = (VertexOut_Body)0;

    UNITY_SETUP_INSTANCE_ID(vin);
    UNITY_TRANSFER_INSTANCE_ID(vin, vout);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(vout);

    vout.PosH = TransformObjectToHClip(vin.PosL.xyz);
    vout.PosW = TransformObjectToWorld(vin.PosL.xyz);
    vout.NormalW = TransformObjectToWorldNormal(vin.NormalL);
    vout.TangentW = TransformObjectToWorldDir(vin.TangentL.xyz);
    vout.BitangentW = cross(vout.NormalW, vout.TangentW) * vin.TangentL.w * GetOddNegativeScale();
    vout.Color = vin.Color;
    vout.TexC.xy = vin.TexC.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    vout.TexC.zw = vin.uv1.xy;
    vout.screenUV = vout.PosH.xy / vout.PosH.w;
    return vout;
}

half4 PSBody(VertexOut_Body pin) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(pin);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(pin);
    return half4(1,1,1,1);
}
#endif