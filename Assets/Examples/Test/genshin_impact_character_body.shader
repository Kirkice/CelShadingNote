Shader "genshin_impact/character/body"
{
    Properties
    {
        _MainTex                            ("Texture", 2D)                             = "white" {}
        _OutlineColor                       ("Outline Color", Color)                    = (0, 0, 0, 0.8)
        _OutlineSkinColor                   ("Outline Skin Color", Color)               = (0, 0, 0, 0.8)
        _OutlineWidth                       ("Width", Range(0, 10))                     = 1.0
        

        [HDR]_OutLineMainLightColor         ("DirectColor", color)                      = (1,1,1,0.5)
        _OutLineMainLightOffset             ("DirectOffset", Range(-1, 1))              = 0.0
        [HDR]_OutlineAdditionalLightColor   ("AdditionalLightColor", color)             = (1,1,1,0.5)
        _OutlineAdditionalLightOffset       ("AdditionalLightOffset", Range(-1, 1))     = 0.0
        
        _OutlineZOffset                     ("Outline ZOffset", Float)                  = 0.1
        _AlphaClip                          ("Alpha Clip",Range(0,1))                   = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        
        //	01 OutLine Pass
        pass
        {
            Name "OutLine"
            Tags
            {
                "LightMode" = "OutLine"
            }

            Cull Front
            HLSLPROGRAM
            #include "character_outline_pass.hlsl"
            #pragma vertex VSOutline
            #pragma fragment PSSkinOutline
            ENDHLSL
        }

        //	02 ForwardRender Pass
        pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            HLSLPROGRAM
            #include "character_main_pass.hlsl"
            #pragma vertex VSBody
            #pragma fragment PSBody
            ENDHLSL
        }

        //	03 ShadowCaster Pass
//        Pass
//        {
//            Name "ShadowCaster"
//            Tags
//            {
//                "LightMode" = "ShadowCaster"
//            }
//
//            HLSLPROGRAM
//            #pragma vertex VSShadow
//            #pragma fragment PSShadow
//            #include "mc_character_pass.hlsl"
//            ENDHLSL
//        }

//        //	04 DepthOnly Pass
//        Pass
//        {
//            Name "DepthOnly"
//            Tags
//            {
//                "LightMode" = "DepthOnly"
//            }
//
//            HLSLPROGRAM
//            #pragma vertex VSDepthOnly
//            #pragma fragment PSDepthOnly
//            #include "mc_depthonly_pass.hlsl"
//            ENDHLSL
//        }
    }
}
