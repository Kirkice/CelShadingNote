Shader "terrain(pcg)"
{
    Properties
    {
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
