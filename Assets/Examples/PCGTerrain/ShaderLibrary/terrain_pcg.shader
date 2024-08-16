Shader "terrain(pcg)"
{
    Properties
    {
        [Header(Channel0)][Space]
        _AlbedoTex0 ("Albedo0", 2D) = "" {}
        _NormalTex0 ("Normal0", 2D) = "" {}
        _TangentTex0 ("Tangent0", 2D) = "" {}
        _NormalStrength0 ("Normal Strength0", Range(0.0, 3.0)) = 1.0
        _BaseColor0("Base Color0", Color) = (1, 1, 1, 1)
        _Metallic0 ("Metallic0", Range(0.0, 1.0)) = 0
        _Subsurface0 ("Subsurface0", Range(0.0, 1.0)) = 0
        _Specular0 ("Specular0", Range(0.0, 2.0)) = 0.5
        _RoughnessTex0 ("Roughness Map0", 2D) = "" {}
        _RoughnessMapMod0 ("Roughness Map Mod0", Range(0.0, 1.0)) = 0.5
        _Roughness0 ("Roughness0", Range(0.0, 1.0)) = 0.5
        _SpecularTint0 ("Specular Tint0", Range(0.0, 1.0)) = 0.0
        _Anisotropic0 ("Anisotropic0", Range(0.0, 1.0)) = 0.0
        _Sheen0 ("Sheen0", Range(0.0, 1.0)) = 0.0
        _SheenTint0 ("Sheen Tint0", Range(0.0, 1.0)) = 0.5
        _ClearCoat0 ("Clear Coat0", Range(0.0, 1.0)) = 0.0
        _ClearCoatGloss0 ("Clear Coat Gloss0", Range(0.0, 1.0)) = 1.0
        _SkyboxCube0 ("Skybox0", Cube) = "" {}
        _IndirectF0_0 ("Indirect Min Reflectance0", Range(0.0, 1.0)) = 0.0
        _IndirectF90_0 ("Indirect Max Reflectance0", Range(0.0, 1.0)) = 0.0

        [Header(Channel1)][Space]
        _AlbedoTex1 ("Albedo1", 2D) = "" {}
        _NormalTex1 ("Normal1", 2D) = "" {}
        _TangentTex1 ("Tangent1", 2D) = "" {}
        _NormalStrength1 ("Normal Strength1", Range(0.0, 3.0)) = 1.0
        _BaseColor1("Base Color1", Color) = (1, 1, 1, 1)
        _Metallic1 ("Metallic1", Range(0.0, 1.0)) = 0
        _Subsurface1 ("Subsurface1", Range(0.0, 1.0)) = 0
        _Specular1 ("Specular1", Range(0.0, 2.0)) = 0.5
        _RoughnessTex1 ("Roughness Map1", 2D) = "" {}
        _RoughnessMapMod1 ("Roughness Map Mod1", Range(0.0, 1.0)) = 0.5
        _Roughness1 ("Roughness1", Range(0.0, 1.0)) = 0.5
        _SpecularTint1 ("Specular Tint1", Range(0.0, 1.0)) = 0.0
        _Anisotropic1 ("Anisotropic1", Range(0.0, 1.0)) = 0.0
        _Sheen1 ("Sheen1", Range(0.0, 1.0)) = 0.0
        _SheenTint1 ("Sheen Tint1", Range(0.0, 1.0)) = 0.5
        _ClearCoat1 ("Clear Coat1", Range(0.0, 1.0)) = 0.0
        _ClearCoatGloss1 ("Clear Coat Gloss1", Range(0.0, 1.0)) = 1.0
        _SkyboxCube1 ("Skybox1", Cube) = "" {}
        _IndirectF0_1 ("Indirect Min Reflectance1", Range(0.0, 1.0)) = 0.0
        _IndirectF90_1 ("Indirect Max Reflectance1", Range(0.0, 1.0)) = 0.0
        
        [Header(Channel2)][Space]
        _AlbedoTex2 ("Albedo2", 2D) = "" {}
        _NormalTex2 ("Normal2", 2D) = "" {}
        _TangentTex2 ("Tangent2", 2D) = "" {}
        _NormalStrength2 ("Normal Strength2", Range(0.0, 3.0)) = 1.0
        _BaseColor2("Base Color2", Color) = (1, 1, 1, 1)
        _Metallic2 ("Metallic2", Range(0.0, 1.0)) = 0
        _Subsurface2 ("Subsurface2", Range(0.0, 1.0)) = 0
        _Specular2 ("Specular2", Range(0.0, 2.0)) = 0.5
        _RoughnessTex2 ("Roughness Map2", 2D) = "" {}
        _RoughnessMapMod2 ("Roughness Map Mod2", Range(0.0, 1.0)) = 0.5
        _Roughness2 ("Roughness2", Range(0.0, 1.0)) = 0.5
        _SpecularTint2 ("Specular Tint2", Range(0.0, 1.0)) = 0.0
        _Anisotropic2 ("Anisotropic2", Range(0.0, 1.0)) = 0.0
        _Sheen2 ("Sheen2", Range(0.0, 1.0)) = 0.0
        _SheenTint2 ("Sheen Tint2", Range(0.0, 1.0)) = 0.5
        _ClearCoat2 ("Clear Coat2", Range(0.0, 1.0)) = 0.0
        _ClearCoatGloss2 ("Clear Coat Gloss2", Range(0.0, 1.0)) = 1.0
        _SkyboxCube2 ("Skybox2", Cube) = "" {}
        _IndirectF0_2 ("Indirect Min Reflectance2", Range(0.0, 1.0)) = 0.0
        _IndirectF90_2 ("Indirect Max Reflectance2", Range(0.0, 1.0)) = 0.0
        
        [Header(Terrain)][Space]
        _TerrainTillingOffset("Terrain(Tilling Offset)", Vector) = (1,1,0,0)
        _MaxHeight("Max Height", Range(0,10)) = 0
        _TerrainPower("Terrain Power", Range(1,10)) = 1
        _TerrainStrength("Terrain Strength", Range(1,10)) = 1
        
        [Header(Tess)][Space]
        [KeywordEnum(integer, fractional_even, fractional_odd)]_Partitioning ("Partitioning Mode", Float) = 0
        [KeywordEnum(triangle_cw, triangle_ccw)]_Outputtopology ("Outputtopology Mode", Float) = 0
        _EdgeFactor ("EdgeFactor", Range(1,70)) = 4 
        _InsideFactor ("InsideFactor", Range(1,70)) = 4 
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        
        pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back
            HLSLPROGRAM
            #pragma target 4.6 
            #include "terrain_pass.hlsl"

            #pragma multi_compile _PARTITIONING_INTEGER _PARTITIONING_FRACTIONAL_EVEN _PARTITIONING_FRACTIONAL_ODD 
            #pragma multi_compile _OUTPUTTOPOLOGY_TRIANGLE_CW _OUTPUTTOPOLOGY_TRIANGLE_CCW 
            #pragma vertex VSTerrain
            #pragma hull HSTerrain 
            #pragma domain DSTerrain
            // #pragma geometry GSTerrain
            #pragma fragment PSTerrain
            ENDHLSL
        }
    }
}
