Shader "Outline"
{
    Properties
    {
        //  OutLine Setting
        _OutlineColor ("OutLine Color", Color) = (0.106,0.0902,0.0784,1)
        _OutlineSkinColor("OutLine Skin Color",Color) = (1,1,1,1)
        _OutlineWidth("Outline Width", Range (0, 3)) = 1.0
        _OutlineWidthParams("Outline Width Params", Vector) = (0,6,0.1,0.6)
        _OutlineZOffset("Outline Z Offset", Float) = 0.1
        _ScreenOffset("Screen Offset", Vector) = (0,0,0,0)
    }
    SubShader
    {
        pass
        {
            Name "OutLine"
            Tags
            {
                "LightMode" = "OutLine"
            }
        
            Cull Front
            HLSLPROGRAM
            #include "mc_outline_pass.hlsl"
            #pragma vertex VSOutline
            #pragma fragment PSSkinOutline
            ENDHLSL
        }

        //        Pass
        //        {
        //            Tags
        //            {
        //                "LightMode" = "OutLine"
        //            }
        //            Cull Front
        //            HLSLPROGRAM
        //            #pragma vertex VS
        //            #pragma fragment PS
        //            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //            struct VertexIn
        //            {
        //                float4 PosL : POSITION;
        //                float2 TexC : TEXCOORD0;
        //                float3 normal : NORMAL;
        //                float4 tangent : TANGENT;
        //            };
        //
        //            struct VertexOut
        //            {
        //                float4 PosH : SV_POSITION;
        //                float2 TexC : TEXCOORD0;
        //            };
        //
        //            CBUFFER_START(UnityPerMaterial)
        //            half _OutlineWidth;
        //            half4 _OutlineSkinColor;
        //            CBUFFER_END
        //
        //            VertexOut VS(VertexIn vin)
        //            {
        //                VertexOut vout;
        //                vout.PosH = TransformObjectToHClip(float4(vin.PosL.xyz + vin.tangent * _OutlineWidth * 0.1 ,1));
        //                vout.TexC = vin.TexC;
        //                return vout;
        //            }
        //
        //            half4 PS(VertexOut pin) : SV_Target
        //            {
        //                half4 color = _OutlineSkinColor;
        //                return color; 
        //            }
        //            ENDHLSL
        //        }

//        Pass
//        {
//            Tags
//            {
//                "LightMode" = "UniversalForward"
//            }
//            HLSLPROGRAM
//            #pragma vertex VS
//            #pragma fragment PS
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//            struct VertexIn
//            {
//                float4 PosL : POSITION;
//                float2 TexC : TEXCOORD0;
//                float2 TexC02 : TEXCOORD1;
//            };
//
//            struct VertexOut
//            {
//                float4 PosH : SV_POSITION;
//                float2 TexC : TEXCOORD0;
//                float2 TexC02 : TEXCOORD1;
//            };
//
//
//            VertexOut VS(VertexIn vin)
//            {
//                VertexOut vout;
//                vout.PosH = TransformObjectToHClip(vin.PosL);
//                vout.TexC = vin.TexC;
//                vout.TexC02 = vin.TexC02;
//                return vout;
//            }
//
//            half4 PS(VertexOut pin) : SV_Target
//            {
//                float2 uv = pin.TexC02 * 2 - 1;
//                float3 normal = float3(uv, sqrt(1 - dot(uv,uv)));
//                return float4(normal,1);
//            }
//            ENDHLSL
//        }
    }
}