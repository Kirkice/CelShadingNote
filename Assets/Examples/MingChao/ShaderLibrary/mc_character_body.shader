Shader "mingchao/character/body"
{
    Properties
    {
        //  Texture Settings 
        _MainTex("Base Texture", 2D) = "white" {}
        _NormalTex("Normal Texture", 2D) = "white"{}
        
        //  OutLine Setting
        _OutlineColor ("OutLine Color", Color) = (0.106,0.0902,0.0784,1)
        _OutlineSkinColor("OutLine Skin Color",Color) = (1,1,1,1)
        _OutlineWidth("Outline Width", Range (0, 3)) = 1.0
        _OutlineWidthParams("Outline Width Params", Vector) = (0,6,0.1,0.6)
        _OutlineZOffset("Outline Z Offset", Float) = 0.1
        _ScreenOffset("Screen Offset", Vector) = (0,0,0,0)
        
        //  PBR Settings
        _Metallic ("Metallic", Range(0.0, 1.0)) = 0
        _Subsurface ("Subsurface", Range(0.0, 1.0)) = 0
        _Specular ("Specular", Range(0.0, 2.0)) = 0.5
        _Roughness ("Roughness", Range(0.0, 1.0)) = 0.5
        _SpecularTint ("Specular Tint", Range(0.0, 1.0)) = 0.0
        _Anisotropic ("Anisotropic", Range(0.0, 1.0)) = 0.0
        _Sheen ("Sheen", Range(0.0, 1.0)) = 0.0
        _SheenTint ("Sheen Tint", Range(0.0, 1.0)) = 0.5
        _ClearCoat ("Clear Coat", Range(0.0, 1.0)) = 0.0
        _ClearCoatGloss ("Clear Coat Gloss", Range(0.0, 1.0)) = 1.0
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
            #include "mc_outline_pass.hlsl"
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
            #include "mc_character_pass.hlsl"
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
            #include "mc_character_pass.hlsl"
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
            #include "mc_depthonly_pass.hlsl"
            ENDHLSL
        }
    }
}
