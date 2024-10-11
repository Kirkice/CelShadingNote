Shader "gf2_exillium/character/body"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        
        //	02 ForwardRender Pass
        pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            HLSLPROGRAM
            #include "gf2_character_pass.hlsl"
            #pragma vertex VSBody
            #pragma fragment PSBody
            ENDHLSL
        }

        //	03 ShadowCaster Pass
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            HLSLPROGRAM
            #pragma vertex VSShadow
            #pragma fragment PSShadow 
            #include "gf2_character_pass.hlsl"
            ENDHLSL
        }

        //	04 DepthOnly Pass
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            HLSLPROGRAM
            #pragma vertex VSDepthOnly
            #pragma fragment PSDepthOnly
            #include "gf2_depthonly_pass.hlsl"
            ENDHLSL
        }
    }
}
