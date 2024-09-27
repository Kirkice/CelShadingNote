Shader "Demo/UseGrabPass"
{
    Properties
    {
    }
    SubShader
    {
         Tags
        {
            "RenderType" = "Transparent" "RenderPipeline" = "UniversalRenderPipeline"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            HLSLPROGRAM
            #pragma vertex VS
            #pragma fragment PS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct VertexIn
            {
                float4 PosL : POSITION;
                float2 TexC : TEXCOORD0;
            };
            
            struct VertexOut
            {
                float4 PosH : SV_POSITION;
                float4 TexC : TEXCOORD0;
            };

            TEXTURE2D(_FinalTexture);
            SAMPLER(sampler_FinalTexture); 

            VertexOut VS(VertexIn vin)
            {
                VertexOut vout = (VertexOut)0;
                vout.PosH = TransformObjectToHClip(vin.PosL);
                vout.TexC.xy = vin.TexC;
                return vout;
            }

            half4 PS(VertexOut pin) : SV_Target
            {
                return SAMPLE_TEXTURE2D(_FinalTexture, sampler_FinalTexture, pin.TexC);
            }
            
            ENDHLSL
        }
    }
}
