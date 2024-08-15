#ifndef TERRAIN_PASS_INCLUDE
#define TERRAIN_PASS_INCLUDE

#include "terrain_input.hlsl"

struct Attributes
{
    float4 position : POSITION;
    float2 texcoord : TEXCOORD0;
};

struct Varyings
{
    float4 positionOS : INTERNALTESSPOS;
    float2 texcoord : TEXCOORD0;
};

struct PatchTess
{  
    float edgeFactor[3] : SV_TESSFACTOR;
    float insideFactor  : SV_INSIDETESSFACTOR;
};

struct HullOut
{
    float3 positionOS : INTERNALTESSPOS; 
    float2 texcoord : TEXCOORD0;
};

struct DomainOut
{
    float4 positionCS : SV_POSITION;
    float2 texcoord : TEXCOORD0; 
};

Varyings VSTerrain(Attributes input)
{
    Varyings output = (Varyings)0;

    output.texcoord = input.texcoord;
    output.positionOS = input.position;
    return output;
}

PatchTess PatchConstant (InputPatch<Varyings,3> patch, uint patchID : SV_PrimitiveID)
{ 
    PatchTess o;
    o.edgeFactor[0] = _EdgeFactor;
    o.edgeFactor[1] = _EdgeFactor; 
    o.edgeFactor[2] = _EdgeFactor;
    o.insideFactor  = _InsideFactor;
    return o;
}

[domain("tri")]   
#if _PARTITIONING_INTEGER
[partitioning("integer")] 
#elif _PARTITIONING_FRACTIONAL_EVEN
[partitioning("fractional_even")] 
#elif _PARTITIONING_FRACTIONAL_ODD
[partitioning("fractional_odd")]    
#endif 

#if _OUTPUTTOPOLOGY_TRIANGLE_CW
[outputtopology("triangle_cw")] 
#elif _OUTPUTTOPOLOGY_TRIANGLE_CCW
[outputtopology("triangle_ccw")] 
#endif

[patchconstantfunc("PatchConstant")] 
[outputcontrolpoints(3)]                 
[maxtessfactor(64.0f)]                 
HullOut HSTerrain (InputPatch<Varyings,3> patch,uint id : SV_OutputControlPointID){  
    HullOut o;
    o.positionOS = patch[id].positionOS;
    o.texcoord = patch[id].texcoord; 
    return o;
}

[domain("tri")]      
DomainOut DSTerrain (PatchTess tessFactors, const OutputPatch<HullOut,3> patch, float3 bary : SV_DOMAINLOCATION)
{  
    float3 positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z; 
    float2 texcoord   = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
       
    DomainOut output;
    half noise = ComputePerlinFBM(texcoord * _TerrainTillingOffset.xy + _TerrainTillingOffset.zw);
    noise = saturate(saturate(pow(noise, _TerrainPower)) * _TerrainStrength);
    half height = Remap(0,1,0,_MaxHeight,noise);
    positionOS.y += height;
    
    output.positionCS = TransformObjectToHClip(positionOS);
    output.texcoord = texcoord;
    return output; 
}
half4 PSTerrain(Varyings input) : SV_TARGET
{
    return half4(1,1,1,1);
}

#endif