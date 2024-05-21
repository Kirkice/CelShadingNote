#ifndef __PROBEVOLUME_HLSL__
#define __PROBEVOLUME_HLSL__

#if defined(SHADER_API_MOBILE) || defined(SHADER_API_SWITCH)
//#define USE_APV_TEXTURE_HALF
#endif // SHADER_API_MOBILE || SHADER_API_SWITCH

#include "Packages/com.unity.render-pipelines.core/Runtime/Lighting/ProbeVolume/ShaderVariablesProbeVolumes.cs.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SphericalHarmonics.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

// Unpack variables
#define _WorldOffset _Offset_IndirectionEntryDim.xyz
#define _GlobalIndirectionEntryDim _Offset_IndirectionEntryDim.w
#define _MinBrickSize _PoolDim_MinBrickSize.w
#define _PoolDim _PoolDim_MinBrickSize.xyz
#define _RcpPoolDim _RcpPoolDim_XY.xyz
#define _RcpPoolDimXY _RcpPoolDim_XY.w
#define _MinEntryPosition _MinEntryPos_Noise.xyz
#define _PVSamplingNoise _MinEntryPos_Noise.w
#define _GlobalIndirectionDimension _IndicesDim_FrameIndex.xyz
#define _NoiseFrameIndex _IndicesDim_FrameIndex.w
#define _NormalBias _Biases_NormalizationClamp.x
#define _ViewBias _Biases_NormalizationClamp.y
#define _Weight _Weight_MinLoadedCellInEntries.x
#define _MinLoadedCellInEntries _Weight_MinLoadedCellInEntries.yzw
#define _MaxLoadedCellInEntries _MaxLoadedCellInEntries_LayerCount.xyz
#define _ProbeLayerCount (int)(_MaxLoadedCellInEntries_LayerCount.w)
#define _MinReflProbeNormalizationFactor _Biases_NormalizationClamp.z
#define _MaxReflProbeNormalizationFactor _Biases_NormalizationClamp.w
#define _LeakReductionMode _LeakReduction_SkyOcclusion.x
#define _MinValidNormalWeight _LeakReduction_SkyOcclusion.y
#define _SkyOcclusionIntensity _LeakReduction_SkyOcclusion.z
#define _EnableSkyOcclusionShadingDirection _LeakReduction_SkyOcclusion.w

#ifndef DECODE_SH
#include "Packages/com.unity.render-pipelines.core/Runtime/Lighting/ProbeVolume/DecodeSH.hlsl"
#endif

#ifndef __AMBIENTPROBE_HLSL__
float3 EvaluateAmbientProbe(float3 normalWS)
{
    return float3(0, 0, 0);
}
#endif

#ifndef UNITY_SHADER_VARIABLES_INCLUDED
SAMPLER(s_linear_clamp_sampler);
SAMPLER(s_point_clamp_sampler);
#endif

// TODO: Remove define when we are sure about what to do with this.
#define MANUAL_FILTERING 0

#ifdef USE_APV_TEXTURE_HALF
#define TEXTURE3D_APV TEXTURE3D_HALF
#else
#define TEXTURE3D_APV TEXTURE3D
#endif

struct APVResources
{
    StructuredBuffer<int> index;
    StructuredBuffer<float3> SkyPrecomputedDirections;

    TEXTURE3D_APV(L0_L1Rx);
    TEXTURE3D_APV(L1G_L1Ry);
    TEXTURE3D_APV(L1B_L1Rz);
    TEXTURE3D_APV(L2_0);
    TEXTURE3D_APV(L2_1);
    TEXTURE3D_APV(L2_2);
    TEXTURE3D_APV(L2_3);
    TEXTURE3D_APV(Validity);

    TEXTURE3D_APV(SkyOcclusionL0L1);
    TEXTURE3D(SkyShadingDirectionIndices);
};

struct APVResourcesRW
{
    RWTexture3D<float4> L0_L1Rx;
    RWTexture3D<float4> L1G_L1Ry;
    RWTexture3D<float4> L1B_L1Rz;
    RWTexture3D<float4> L2_0;
    RWTexture3D<float4> L2_1;
    RWTexture3D<float4> L2_2;
    RWTexture3D<float4> L2_3;
};

#define LOAD_APV_RES_L1(res, target) \
    res.L0_L1Rx  = CALL_MERGE_NAME(target, _L0_L1Rx); \
    res.L1G_L1Ry = CALL_MERGE_NAME(target, _L1G_L1Ry); \
    res.L1B_L1Rz = CALL_MERGE_NAME(target, _L1B_L1Rz);
#define LOAD_APV_RES_L2(res, target) \
    res.L2_0 = CALL_MERGE_NAME(target, _L2_0); \
    res.L2_1 = CALL_MERGE_NAME(target, _L2_1); \
    res.L2_2 = CALL_MERGE_NAME(target, _L2_2); \
    res.L2_3 = CALL_MERGE_NAME(target, _L2_3);

#ifndef PROBE_VOLUMES_L2
# define LOAD_APV_RES(res, target) LOAD_APV_RES_L1(res, target)
#else
# define LOAD_APV_RES(res, target) \
    LOAD_APV_RES_L1(res, target) \
    LOAD_APV_RES_L2(res, target)
#endif

struct APVSample
{
    half3 L0;
    half3 L1_R;
    half3 L1_G;
    half3 L1_B;
#ifdef PROBE_VOLUMES_L2
    half4 L2_R;
    half4 L2_G;
    half4 L2_B;
    half3 L2_C;
#endif // PROBE_VOLUMES_L2

    float4 skyOcclusionL0L1;
    float3 skyShadingDirection;

#define APV_SAMPLE_STATUS_INVALID -1
#define APV_SAMPLE_STATUS_ENCODED 0
#define APV_SAMPLE_STATUS_DECODED 1

    int status;

    // Note: at the moment this is called at the moment the struct is built, but it is kept as a separate step
    // as ideally should be called as far as possible from sample to allow for latency hiding.
    void Decode()
    {
        if (status == APV_SAMPLE_STATUS_ENCODED)
        {
            L1_R = DecodeSH(L0.r, L1_R);
            L1_G = DecodeSH(L0.g, L1_G);
            L1_B = DecodeSH(L0.b, L1_B);
#ifdef PROBE_VOLUMES_L2
            DecodeSH_L2(L0, L2_R, L2_G, L2_B, L2_C);
#endif // PROBE_VOLUMES_L2

            status = APV_SAMPLE_STATUS_DECODED;
        }
    }

    void Encode()
    {
        if (status == APV_SAMPLE_STATUS_DECODED)
        {
            L1_R = EncodeSH(L0.r, L1_R);
            L1_G = EncodeSH(L0.g, L1_G);
            L1_B = EncodeSH(L0.b, L1_B);
#ifdef PROBE_VOLUMES_L2
            EncodeSH_L2(L0, L2_R, L2_G, L2_B, L2_C);
#endif // PROBE_VOLUMES_L2

            status = APV_SAMPLE_STATUS_ENCODED;
        }
    }
};

// Resources required for APV
StructuredBuffer<int> _APVResIndex;
StructuredBuffer<uint3> _APVResCellIndices;
StructuredBuffer<float3> _SkyPrecomputedDirections;

TEXTURE3D_APV(_APVResL0_L1Rx);

TEXTURE3D_APV(_APVResL1G_L1Ry);
TEXTURE3D_APV(_APVResL1B_L1Rz);
TEXTURE3D_APV(_APVResL2_0);
TEXTURE3D_APV(_APVResL2_1);
TEXTURE3D_APV(_APVResL2_2);
TEXTURE3D_APV(_APVResL2_3);

TEXTURE3D_APV(_APVResValidity);

TEXTURE3D_APV(_SkyOcclusionTexL0L1);
TEXTURE3D(_SkyShadingDirectionIndicesTex);


// -------------------------------------------------------------
// Various weighting functions for occlusion or helper functions.
// -------------------------------------------------------------
float3 AddNoiseToSamplingPosition(float3 posWS, float2 positionSS, float3 direction)
{
#ifdef UNITY_SPACE_TRANSFORMS_INCLUDED
    float3 right = mul((float3x3)GetViewToWorldMatrix(), float3(1.0, 0.0, 0.0));
    float3 top = mul((float3x3)GetViewToWorldMatrix(), float3(0.0, 1.0, 0.0));
    float noise01 = InterleavedGradientNoise(positionSS, _NoiseFrameIndex);
    float noise02 = frac(noise01 * 100.0);
    float noise03 = frac(noise01 * 1000.0);
    direction += top * (noise02 - 0.5) + right * (noise03 - 0.5);
    return _PVSamplingNoise > 0 ? posWS + noise01 * _PVSamplingNoise * direction : posWS;
#else
    return posWS;
#endif
}

uint3 GetSampleOffset(uint i)
{
    return uint3(i, i >> 1, i >> 2) & 1;
}

// The validity mask is sampled once and contains a binary info on whether a probe neighbour (relevant for trilinear) is to be used
// or not. The entry in the mask uses the same mapping that GetSampleOffset above uses.
half GetValidityWeight(uint offset, uint validityMask)
{
    uint mask = 1U << offset;
    return (validityMask & mask) > 0 ? 1 : 0;
}

float ProbeDistance(uint subdiv)
{
    return pow(3, subdiv) * _MinBrickSize / 3.0f;
}

half ProbeDistanceHalf(uint subdiv)
{
    return pow(half(3), half(subdiv)) * half(_MinBrickSize) / 3.0;
}

float3 GetSnappedProbePosition(float3 posWS, uint subdiv)
{
    float3 distBetweenProbes = ProbeDistance(subdiv);
    float3 dividedPos = posWS / distBetweenProbes;
    return (dividedPos - frac(dividedPos)) * distBetweenProbes;
}

float GetNormalWeight(uint3 offset, float3 posWS, float3 sample0Pos, float3 normalWS, uint subdiv)
{
    // TODO: This can be optimized.
    float3 samplePos = (sample0Pos - posWS) + (float3)offset * ProbeDistance(subdiv);
    float3 vecToProbe = normalize(samplePos);
    float weight = saturate(dot(vecToProbe, normalWS) - _MinValidNormalWeight);
    return weight;
}

half GetNormalWeightHalf(uint3 offset, float3 posWS, float3 sample0Pos, float3 normalWS, uint subdiv)
{
    // TODO: This can be optimized.
    half3 samplePos = (half3)(sample0Pos - posWS) + (half3)offset * ProbeDistanceHalf(subdiv);
    half3 vecToProbe = normalize(samplePos);
    half weight = saturate(dot(vecToProbe, (half3)normalWS) - (half)_MinValidNormalWeight);
    return weight;
}

// -------------------------------------------------------------
// Indexing functions
// -------------------------------------------------------------

bool LoadCellIndexMetaData(int cellFlatIdx, out int chunkIndex, out int stepSize, out int3 minRelativeIdx, out int3 maxRelativeIdxPlusOne)
{
    bool cellIsLoaded = false;
    uint3 metaData = _APVResCellIndices[cellFlatIdx];

    if (metaData.x != 0xFFFFFFFF)
    {
        chunkIndex = metaData.x & 0x1FFFFFFF;
        stepSize = round(pow(3, (metaData.x >> 29) & 0x7));

        minRelativeIdx.x = metaData.y & 0x3FF;
        minRelativeIdx.y = (metaData.y >> 10) & 0x3FF;
        minRelativeIdx.z = (metaData.y >> 20) & 0x3FF;

        maxRelativeIdxPlusOne.x = metaData.z & 0x3FF;
        maxRelativeIdxPlusOne.y = (metaData.z >> 10) & 0x3FF;
        maxRelativeIdxPlusOne.z = (metaData.z >> 20) & 0x3FF;
        cellIsLoaded = true;
    }
    else
    {
        chunkIndex = -1;
        stepSize = -1;
        minRelativeIdx = -1;
        maxRelativeIdxPlusOne = -1;
    }

    return cellIsLoaded;
}

uint GetIndexData(APVResources apvRes, float3 posWS)
{
    float3 entryPos = floor(posWS / _GlobalIndirectionEntryDim);
    float3 topLeftEntryWS = entryPos * _GlobalIndirectionEntryDim;

    bool isALoadedCell = all(entryPos >= _MinLoadedCellInEntries) && all(entryPos <= _MaxLoadedCellInEntries);

    // Make sure we start from 0
    int3 entryPosInt = (int3)(entryPos - _MinEntryPosition);

    int flatIdx = dot(entryPosInt, int3(1, (int)_GlobalIndirectionDimension.x, ((int)_GlobalIndirectionDimension.x * (int)_GlobalIndirectionDimension.y)));

    int stepSize = 0;
    int3 minRelativeIdx, maxRelativeIdxPlusOne;
    int chunkIdx = -1;
    bool isValidBrick = false;
    int locationInPhysicalBuffer = 0;

    // Dynamic branch must be enforced to avoid out-of-bounds memory access in LoadCellIndexMetaData
    UNITY_BRANCH if (isALoadedCell)
    {
        if (LoadCellIndexMetaData(flatIdx, chunkIdx, stepSize, minRelativeIdx, maxRelativeIdxPlusOne))
        {
            float3 residualPosWS = posWS - topLeftEntryWS;
            int3 localBrickIndex = floor(residualPosWS / (_MinBrickSize * stepSize));
            localBrickIndex = min(localBrickIndex, (int3)(3 * 3 * 3 - 1)); // due to floating point issue, we may query an invalid brick

            // Out of bounds.
            isValidBrick = all(localBrickIndex >= minRelativeIdx) && all(localBrickIndex < maxRelativeIdxPlusOne);

            int3 sizeOfValid = maxRelativeIdxPlusOne - minRelativeIdx;
            // Relative to valid region
            int3 localRelativeIndexLoc = (localBrickIndex - minRelativeIdx);
            int flattenedLocationInCell = dot(localRelativeIndexLoc, int3(sizeOfValid.y, 1, sizeOfValid.x * sizeOfValid.y));

            locationInPhysicalBuffer = chunkIdx * (int)PROBE_INDEX_CHUNK_SIZE + flattenedLocationInCell;
        }
    }

    uint result = 0xffffffff;

    // Dynamic branch must be enforced to avoid out-of-bounds memory access in the physical APV buffer
    UNITY_BRANCH if (isValidBrick)
    {
        result = apvRes.index[locationInPhysicalBuffer];
    }

    return result;
}

// -------------------------------------------------------------
// Loading functions
// -------------------------------------------------------------
APVResources FillAPVResources()
{
    APVResources apvRes;
    apvRes.index = _APVResIndex;

    apvRes.L0_L1Rx = _APVResL0_L1Rx;

    apvRes.L1G_L1Ry = _APVResL1G_L1Ry;
    apvRes.L1B_L1Rz = _APVResL1B_L1Rz;

    apvRes.L2_0 = _APVResL2_0;
    apvRes.L2_1 = _APVResL2_1;
    apvRes.L2_2 = _APVResL2_2;
    apvRes.L2_3 = _APVResL2_3;

    apvRes.Validity = _APVResValidity;
    apvRes.SkyOcclusionL0L1 = _SkyOcclusionTexL0L1;
    apvRes.SkyShadingDirectionIndices = _SkyShadingDirectionIndicesTex;
    apvRes.SkyPrecomputedDirections = _SkyPrecomputedDirections;

    return apvRes;
}


bool TryToGetPoolUVWAndSubdiv(APVResources apvRes, float3 posWSForSample, out float3 uvw, out uint subdiv)
{
    // resolve the index
    uint packed_pool_idx = GetIndexData(apvRes, posWSForSample.xyz);

    // unpack pool idx
    // size is encoded in the upper 4 bits
    subdiv = (packed_pool_idx >> 28) & 15;

    float   flattened_pool_idx = packed_pool_idx & ((1 << 28) - 1);
    float3 pool_idx;
    pool_idx.z = floor(flattened_pool_idx * _RcpPoolDimXY);
    flattened_pool_idx -= (pool_idx.z * (_PoolDim.x * _PoolDim.y));
    pool_idx.y = floor(flattened_pool_idx * _RcpPoolDim.x);
    pool_idx.x = floor(flattened_pool_idx - (pool_idx.y * _PoolDim.x));

    // calculate uv offset and scale
    float brickSizeWS = pow(3.0, subdiv) * _MinBrickSize;
    float3 offset = frac(posWSForSample.xyz / brickSizeWS);  // [0;1] in brick space
    //offset    = clamp( offset, 0.25, 0.75 );      // [0.25;0.75] in brick space (is this actually necessary?)

    uvw = (pool_idx + 0.5 + (3.0 * offset)) * _RcpPoolDim; // add offset with brick footprint converted to text footprint in pool texel space

    // no valid brick loaded for this index, fallback to ambient probe
    // Note: we could instead early return when we know we'll have invalid UVs, but some bade code gen on Vulkan generates shader warnings if we do.
    return packed_pool_idx != 0xffffffffu;
}

bool TryToGetPoolUVWAndSubdiv(APVResources apvRes, float3 posWS, float3 normalWS, float3 viewDirWS, out float3 uvw, out uint subdiv, out float3 biasedPosWS)
{
    biasedPosWS = (posWS + normalWS * _NormalBias) + viewDirWS * _ViewBias;
    return TryToGetPoolUVWAndSubdiv(apvRes, biasedPosWS, uvw, subdiv);
}

bool TryToGetPoolUVW(APVResources apvRes, float3 posWS, float3 normalWS, float3 viewDir, out float3 uvw)
{
    uint unusedSubdiv;
    float3 unusedPos;
    return TryToGetPoolUVWAndSubdiv(apvRes, posWS, normalWS, viewDir, uvw, unusedSubdiv, unusedPos);
}


APVSample SampleAPV(APVResources apvRes, float3 uvw)
{
    APVSample apvSample;
    half4 L0_L1Rx = half4(SAMPLE_TEXTURE3D_LOD(apvRes.L0_L1Rx, s_linear_clamp_sampler, uvw, 0).rgba);
    half4 L1G_L1Ry = half4(SAMPLE_TEXTURE3D_LOD(apvRes.L1G_L1Ry, s_linear_clamp_sampler, uvw, 0).rgba);
    half4 L1B_L1Rz = half4(SAMPLE_TEXTURE3D_LOD(apvRes.L1B_L1Rz, s_linear_clamp_sampler, uvw, 0).rgba);

    apvSample.L0 = L0_L1Rx.xyz;
    apvSample.L1_R = half3(L0_L1Rx.w, L1G_L1Ry.w, L1B_L1Rz.w);
    apvSample.L1_G = L1G_L1Ry.xyz;
    apvSample.L1_B = L1B_L1Rz.xyz;

#ifdef PROBE_VOLUMES_L2
    apvSample.L2_R = half4(SAMPLE_TEXTURE3D_LOD(apvRes.L2_0, s_linear_clamp_sampler, uvw, 0).rgba);
    apvSample.L2_G = half4(SAMPLE_TEXTURE3D_LOD(apvRes.L2_1, s_linear_clamp_sampler, uvw, 0).rgba);
    apvSample.L2_B = half4(SAMPLE_TEXTURE3D_LOD(apvRes.L2_2, s_linear_clamp_sampler, uvw, 0).rgba);
    apvSample.L2_C = half3(SAMPLE_TEXTURE3D_LOD(apvRes.L2_3, s_linear_clamp_sampler, uvw, 0).rgb);
#endif // PROBE_VOLUMES_L2

    if (_SkyOcclusionIntensity > 0)
        apvSample.skyOcclusionL0L1 = SAMPLE_TEXTURE3D_LOD(apvRes.SkyOcclusionL0L1, s_linear_clamp_sampler, uvw, 0).rgba;
    else
        apvSample.skyOcclusionL0L1 = float4(0, 0, 0, 0);

    if (_EnableSkyOcclusionShadingDirection > 0)
    {
        // No interpolation for sky shading indices
        float3 texCoordFloat = uvw * _PoolDim - 0.5f;
        int3 texCoordInt = texCoordFloat;
        uint index = LOAD_TEXTURE3D(apvRes.SkyShadingDirectionIndices, texCoordInt).x * 255.0;

        if (index == 255)
            apvSample.skyShadingDirection = float3(0, 0, 0);
        else
            apvSample.skyShadingDirection = apvRes.SkyPrecomputedDirections[index].rgb;
    }
    else
        apvSample.skyShadingDirection = float3(0, 0, 0);

    apvSample.status = APV_SAMPLE_STATUS_ENCODED;

    return apvSample;
}

APVSample LoadAndDecodeAPV(APVResources apvRes, int3 loc)
{
    APVSample apvSample;

    half4 L0_L1Rx =  half4(LOAD_TEXTURE3D(apvRes.L0_L1Rx, loc).rgba);
    half4 L1G_L1Ry = half4(LOAD_TEXTURE3D(apvRes.L1G_L1Ry, loc).rgba);
    half4 L1B_L1Rz = half4(LOAD_TEXTURE3D(apvRes.L1B_L1Rz, loc).rgba);

    apvSample.L0 = L0_L1Rx.xyz;
    apvSample.L1_R = half3(L0_L1Rx.w, L1G_L1Ry.w, L1B_L1Rz.w);
    apvSample.L1_G = L1G_L1Ry.xyz;
    apvSample.L1_B = L1B_L1Rz.xyz;

#ifdef PROBE_VOLUMES_L2
    apvSample.L2_R = half4(LOAD_TEXTURE3D(apvRes.L2_0, loc).rgba);
    apvSample.L2_G = half4(LOAD_TEXTURE3D(apvRes.L2_1, loc).rgba);
    apvSample.L2_B = half4(LOAD_TEXTURE3D(apvRes.L2_2, loc).rgba);
    apvSample.L2_C = half3(LOAD_TEXTURE3D(apvRes.L2_3, loc).rgb);
#endif // PROBE_VOLUMES_L2

    apvSample.status = APV_SAMPLE_STATUS_ENCODED;
    apvSample.Decode();

    return apvSample;
}

void WeightSample(inout APVSample apvSample, half weight)
{
    apvSample.L0 *= weight;
    apvSample.L1_R *= weight;
    apvSample.L1_G *= weight;
    apvSample.L1_B *= weight;

#ifdef PROBE_VOLUMES_L2
    apvSample.L2_R *= weight;
    apvSample.L2_G *= weight;
    apvSample.L2_B *= weight;
    apvSample.L2_C *= weight;
#endif // PROBE_VOLUMES_L2
}

void AccumulateSamples(inout APVSample dst, APVSample other, half weight)
{
    WeightSample(other, weight);
    dst.L0   += other.L0;
    dst.L1_R += other.L1_R;
    dst.L1_G += other.L1_G;
    dst.L1_B += other.L1_B;

#ifdef PROBE_VOLUMES_L2
    dst.L2_R += other.L2_R;
    dst.L2_G += other.L2_G;
    dst.L2_B += other.L2_B;
    dst.L2_C += other.L2_C;
#endif // PROBE_VOLUMES_L2
}

uint LoadValidityMask(APVResources apvRes, uint renderingLayer, int3 coord)
{
    float rawValidity = LOAD_TEXTURE3D(apvRes.Validity, coord).x;

    uint validityMask;
    if (_ProbeLayerCount == 1)
    {
        validityMask = rawValidity * 255.0;
    }
    else
    {
        // If the object is on none of the masks, enable all layers to still sample validity correctly
        uint globalLayer = _ProbeVolumeLayerMask[0] | _ProbeVolumeLayerMask[1] | _ProbeVolumeLayerMask[2] | _ProbeVolumeLayerMask[3];
        if ((renderingLayer & globalLayer) == 0) renderingLayer = 0xFFFFFFFF;

        validityMask = 0;
        if ((renderingLayer & _ProbeVolumeLayerMask[0]) != 0)
            validityMask = asuint(rawValidity);
        if ((renderingLayer & _ProbeVolumeLayerMask[1]) != 0)
            validityMask |= asuint(rawValidity) >> 8;
        if ((renderingLayer & _ProbeVolumeLayerMask[2]) != 0)
            validityMask |= asuint(rawValidity) >> 16;
        if ((renderingLayer & _ProbeVolumeLayerMask[3]) != 0)
            validityMask |= asuint(rawValidity) >> 24;
        validityMask = validityMask & 0xFF;
    }

    return validityMask;
}

APVSample ManuallyFilteredSample(APVResources apvRes, float3 posWS, float3 normalWS, uint renderingLayer, int subdiv, float3 biasedPosWS, float3 uvw)
{
    float3 texCoordFloat = uvw * _PoolDim - .5f;
    int3 texCoordInt = texCoordFloat;
    float3 texFrac = frac(texCoordFloat);
    float3 oneMinTexFrac = 1.0f - texFrac;

    bool sampled = false;
    float totalW = 0.0f;

    APVSample baseSample;

    float3 positionCentralProbe = GetSnappedProbePosition(biasedPosWS, subdiv);

    ZERO_INITIALIZE(APVSample, baseSample);

    uint validityMask = LoadValidityMask(apvRes, renderingLayer, texCoordInt);
    for (uint i = 0; i < 8; ++i)
    {
        uint3 offset = GetSampleOffset(i);
        float trilinearW =
            ((offset.x == 1) ? texFrac.x : oneMinTexFrac.x) *
            ((offset.y == 1) ? texFrac.y : oneMinTexFrac.y) *
            ((offset.z == 1) ? texFrac.z : oneMinTexFrac.z);

        half validityWeight = GetValidityWeight(i, validityMask);

        if (validityWeight > 0)
        {
            APVSample apvSample = LoadAndDecodeAPV(apvRes, texCoordInt + offset);
            half geoW = GetNormalWeightHalf(offset, posWS, positionCentralProbe, normalWS, subdiv);

            half finalW = half(geoW * trilinearW);
            AccumulateSamples(baseSample, apvSample, finalW);
            totalW += finalW;
        }
    }

    WeightSample(baseSample, half(rcp(totalW)));

    return baseSample;
}

void WarpUVWLeakReduction(APVResources apvRes, float3 posWS, float3 normalWS, uint renderingLayer, uint subdiv, float3 biasedPosWS, inout float3 uvw, out float3 normalizedOffset, out float validityWeights[8])
{
    float3 texCoordFloat = uvw * _PoolDim - 0.5f;
    int3 texCoordInt = texCoordFloat;
    half3 texFrac = half3(frac(texCoordFloat));
    uint validityMask = LoadValidityMask(apvRes, renderingLayer, texCoordInt);

    if (_LeakReductionMode == APVLEAKREDUCTIONMODE_VALIDITY_AND_NORMAL_BASED || validityMask != 0xFF)
    {
        half4 weights[2];
        half totalW = 0.0;

        float3 positionCentralProbe = GetSnappedProbePosition(biasedPosWS, subdiv);
        half3 oneMinTexFrac = 1.0 - texFrac;
        uint i = 0;

        UNITY_UNROLL
        for (i = 0; i < 8; ++i)
        {
            uint3 offset = GetSampleOffset(i);
            half validityWeight =
                ((offset.x == 1) ? texFrac.x : oneMinTexFrac.x) *
                ((offset.y == 1) ? texFrac.y : oneMinTexFrac.y) *
                ((offset.z == 1) ? texFrac.z : oneMinTexFrac.z);

            validityWeight *= GetValidityWeight(i, validityMask);

            if (_LeakReductionMode == APVLEAKREDUCTIONMODE_VALIDITY_AND_NORMAL_BASED)
                validityWeight *= GetNormalWeightHalf(offset, posWS, positionCentralProbe, normalWS, subdiv);

            half weight = saturate(validityWeight);

            weights[i/4][i%4] = weight;
            totalW += weight;
        }

        half rcpTotalW = rcp(max(0.0001, totalW));
        weights[0] *= rcpTotalW;
        weights[1] *= rcpTotalW;

        half3 fracOffset = -texFrac;

        UNITY_UNROLL
        for (i = 0; i < 8; ++i)
        {
            uint3 offset = GetSampleOffset(i);
            fracOffset += (half3)offset * weights[i/4][i%4];
        }

        uvw = uvw + (float3)fracOffset * _RcpPoolDim;
    }

    // Output values used for debug only
    UNITY_UNROLL
    for (uint i = 0; i < 8; i++)
    {
        int3 probeCoord = GetSampleOffset(i);
        half validityWeight = GetValidityWeight(i, validityMask);
        validityWeights[i] = validityWeight;
    }

    normalizedOffset = (float3)(uvw * _PoolDim - (texCoordInt + 0.5));
}

void WarpUVWLeakReduction(APVResources apvRes, float3 posWS, float3 normalWS, uint renderingLayer, uint subdiv, float3 biasedPosWS, inout float3 uvw)
{
    float3 normalizedOffset;
    float validityWeights[8];
    WarpUVWLeakReduction(apvRes, posWS, normalWS, renderingLayer, subdiv, biasedPosWS, uvw, normalizedOffset, validityWeights);
}

APVSample SampleAPV(APVResources apvRes, float3 posWS, float3 biasNormalWS, uint renderingLayer, float3 viewDir)
{
    APVSample outSample;

    posWS -= _WorldOffset;

    float3 pool_uvw;
    uint subdiv;
    float3 biasedPosWS;
    if (TryToGetPoolUVWAndSubdiv(apvRes, posWS, biasNormalWS, viewDir, pool_uvw, subdiv, biasedPosWS))
    {
#if MANUAL_FILTERING == 1
        if (_LeakReductionMode != 0)
            outSample = ManuallyFilteredSample(apvRes, posWS, biasNormalWS, renderingLayer, subdiv, biasedPosWS, pool_uvw);
        else
            outSample = SampleAPV(apvRes, pool_uvw);
#else
        if (_LeakReductionMode != 0)
        {
            WarpUVWLeakReduction(apvRes, posWS, biasNormalWS, renderingLayer, subdiv, biasedPosWS, pool_uvw);
        }
        outSample = SampleAPV(apvRes, pool_uvw);
#endif
    }
    else
    {
        ZERO_INITIALIZE(APVSample, outSample);
        outSample.status = APV_SAMPLE_STATUS_INVALID;
    }

    return outSample;
}


APVSample SampleAPV(float3 posWS, float3 biasNormalWS, uint renderingLayer, float3 viewDir)
{
    APVResources apvRes = FillAPVResources();
    return SampleAPV(apvRes, posWS, biasNormalWS, renderingLayer, viewDir);
}

// -------------------------------------------------------------
// Dynamic Sky Handling
// -------------------------------------------------------------

// Expects Layout DC, x, y, z
// See on baking side in DynamicGISkyOcclusion.hlsl
float EvalSHSkyOcclusion(float3 dir, APVSample apvSample)
{
    // L0 L1
    float4 temp = float4(kSHBasis0, kSHBasis1 * dir.x, kSHBasis1 * dir.y, kSHBasis1 * dir.z);
    return _SkyOcclusionIntensity * dot(temp, apvSample.skyOcclusionL0L1);
}

float3 EvaluateOccludedSky(APVSample apvSample, float3 N)
{
    float occValue = EvalSHSkyOcclusion(N, apvSample);
    float3 shadingNormal = N;

    if (_EnableSkyOcclusionShadingDirection > 0)
    {
        shadingNormal = apvSample.skyShadingDirection;
        float normSquared = dot(shadingNormal, shadingNormal);
        if (normSquared < 0.2f)
            shadingNormal = N;
        else
        {
            shadingNormal = shadingNormal * rsqrt(normSquared);
        }
    }
    return occValue * EvaluateAmbientProbe(shadingNormal);
}

// -------------------------------------------------------------
// Internal Evaluation functions (avoid usage in caller code outside this file)
// -------------------------------------------------------------
float3 EvaluateAPVL0(APVSample apvSample)
{
    return apvSample.L0;
}

void EvaluateAPVL1(APVSample apvSample, float3 N, out float3 diffuseLighting)
{
    diffuseLighting = SHEvalLinearL1(N, apvSample.L1_R, apvSample.L1_G, apvSample.L1_B);
}

#ifdef PROBE_VOLUMES_L2
void EvaluateAPVL1L2(APVSample apvSample, float3 N, out float3 diffuseLighting)
{
    EvaluateAPVL1(apvSample, N, diffuseLighting);
    diffuseLighting += SHEvalLinearL2(N, apvSample.L2_R, apvSample.L2_G, apvSample.L2_B, float4(apvSample.L2_C, 0.0f));
}
#endif


// -------------------------------------------------------------
// "Public" Evaluation functions, the one that callers outside this file should use
// -------------------------------------------------------------
void EvaluateAdaptiveProbeVolume(APVSample apvSample, float3 normalWS, out float3 bakeDiffuseLighting)
{
    if (apvSample.status != APV_SAMPLE_STATUS_INVALID)
    {
        apvSample.Decode();

#if defined(PROBE_VOLUMES_L1)
        EvaluateAPVL1(apvSample, normalWS, bakeDiffuseLighting);
#elif defined(PROBE_VOLUMES_L2)
        EvaluateAPVL1L2(apvSample, normalWS, bakeDiffuseLighting);
#endif

        bakeDiffuseLighting += apvSample.L0;
        if (_SkyOcclusionIntensity > 0)
            bakeDiffuseLighting += EvaluateOccludedSky(apvSample, normalWS);

        //if (_Weight < 1.f)
        {
            bakeDiffuseLighting = bakeDiffuseLighting * _Weight;
        }
    }
    else
    {
        // no valid brick, fallback to ambient probe
        bakeDiffuseLighting = EvaluateAmbientProbe(normalWS);
    }
}

void EvaluateAdaptiveProbeVolume(APVSample apvSample, float3 normalWS, float3 backNormalWS, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting)
{
    if (apvSample.status != APV_SAMPLE_STATUS_INVALID)
    {
        apvSample.Decode();

#ifdef PROBE_VOLUMES_L1
        EvaluateAPVL1(apvSample, normalWS, bakeDiffuseLighting);
        EvaluateAPVL1(apvSample, backNormalWS, backBakeDiffuseLighting);
#elif defined(PROBE_VOLUMES_L2)
        EvaluateAPVL1L2(apvSample, normalWS, bakeDiffuseLighting);
        EvaluateAPVL1L2(apvSample, backNormalWS, backBakeDiffuseLighting);
#endif

        bakeDiffuseLighting += apvSample.L0;
        backBakeDiffuseLighting += apvSample.L0;
        if (_SkyOcclusionIntensity > 0)
        {
            bakeDiffuseLighting += EvaluateOccludedSky(apvSample, normalWS);
            backBakeDiffuseLighting += EvaluateOccludedSky(apvSample, backNormalWS);
        }

        //if (_Weight < 1.f)
        {
            bakeDiffuseLighting = bakeDiffuseLighting * _Weight;
            backBakeDiffuseLighting = backBakeDiffuseLighting * _Weight;
        }
    }
    else
    {
        // no valid brick, fallback to ambient probe
        bakeDiffuseLighting = EvaluateAmbientProbe(normalWS);
        backBakeDiffuseLighting = EvaluateAmbientProbe(backNormalWS);
    }
}

void EvaluateAdaptiveProbeVolume(in float3 posWS, in float3 normalWS, in float3 backNormalWS, in float3 reflDir, in float3 viewDir,
    in float2 positionSS, in uint renderingLayer, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, out float3 lightingInReflDir)
{
    APVResources apvRes = FillAPVResources();

    posWS = AddNoiseToSamplingPosition(posWS, positionSS, viewDir);

    APVSample apvSample = SampleAPV(posWS, normalWS, renderingLayer, viewDir);

    if (apvSample.status != APV_SAMPLE_STATUS_INVALID)
    {
#if MANUAL_FILTERING == 0
        apvSample.Decode();
#endif

#ifdef PROBE_VOLUMES_L1
        EvaluateAPVL1(apvSample, normalWS, bakeDiffuseLighting);
        EvaluateAPVL1(apvSample, backNormalWS, backBakeDiffuseLighting);
        EvaluateAPVL1(apvSample, reflDir, lightingInReflDir);
#elif defined(PROBE_VOLUMES_L2)
        EvaluateAPVL1L2(apvSample, normalWS, bakeDiffuseLighting);
        EvaluateAPVL1L2(apvSample, backNormalWS, backBakeDiffuseLighting);
        EvaluateAPVL1L2(apvSample, reflDir, lightingInReflDir);
#endif

        bakeDiffuseLighting += apvSample.L0;
        backBakeDiffuseLighting += apvSample.L0;
        lightingInReflDir += apvSample.L0;
        if (_SkyOcclusionIntensity > 0)
        {
            bakeDiffuseLighting += EvaluateOccludedSky(apvSample, normalWS);
            backBakeDiffuseLighting += EvaluateOccludedSky(apvSample, backNormalWS);
            lightingInReflDir += EvaluateOccludedSky(apvSample, reflDir);
        }

        //if (_Weight < 1.f)
        {
            bakeDiffuseLighting = bakeDiffuseLighting * _Weight;
            backBakeDiffuseLighting = backBakeDiffuseLighting * _Weight;
        }
    }
    else
    {
        bakeDiffuseLighting = EvaluateAmbientProbe(normalWS);
        backBakeDiffuseLighting = EvaluateAmbientProbe(backNormalWS);
        lightingInReflDir = -1;
    }
}

void EvaluateAdaptiveProbeVolume(in float3 posWS, in float3 normalWS, in float3 backNormalWS, in float3 viewDir,
    in float2 positionSS, in uint renderingLayer, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting)
{
    bakeDiffuseLighting = float3(0.0, 0.0, 0.0);
    backBakeDiffuseLighting = float3(0.0, 0.0, 0.0);

    posWS = AddNoiseToSamplingPosition(posWS, positionSS, viewDir);

    APVSample apvSample = SampleAPV(posWS, normalWS, renderingLayer, viewDir);
    EvaluateAdaptiveProbeVolume(apvSample, normalWS, backNormalWS, bakeDiffuseLighting, backBakeDiffuseLighting);
}

void EvaluateAdaptiveProbeVolume(in float3 posWS, in float3 normalWS, in float3 viewDir, in float2 positionSS, in uint renderingLayer,
    out float3 bakeDiffuseLighting)
{
    bakeDiffuseLighting = float3(0.0, 0.0, 0.0);

    posWS = AddNoiseToSamplingPosition(posWS, positionSS, viewDir);

    APVSample apvSample = SampleAPV(posWS, normalWS, renderingLayer, viewDir);
    EvaluateAdaptiveProbeVolume(apvSample, normalWS, bakeDiffuseLighting);
}

void EvaluateAdaptiveProbeVolume(in float3 posWS, in float2 positionSS, out float3 bakeDiffuseLighting)
{
    APVResources apvRes = FillAPVResources();

    posWS = AddNoiseToSamplingPosition(posWS, positionSS, 1);
    posWS -= _WorldOffset;

    float3 uvw;
    if (TryToGetPoolUVW(apvRes, posWS, 0, 0, uvw))
    {
        bakeDiffuseLighting = SAMPLE_TEXTURE3D_LOD(apvRes.L0_L1Rx, s_linear_clamp_sampler, uvw, 0).rgb;
    }
    else
    {
        bakeDiffuseLighting = EvaluateAmbientProbe(0);
    }
}

// public APIs for backward compatibility
// to be removed after Unity 6
void EvaluateAdaptiveProbeVolume(in float3 posWS, in float3 normalWS, in float3 backNormalWS, in float3 reflDir, in float3 viewDir, in float2 positionSS, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting, out float3 lightingInReflDir)
{ EvaluateAdaptiveProbeVolume(posWS, normalWS, backNormalWS, reflDir, viewDir, positionSS, 0xFFFFFFFF, bakeDiffuseLighting, backBakeDiffuseLighting, lightingInReflDir); }
void EvaluateAdaptiveProbeVolume(in float3 posWS, in float3 normalWS, in float3 backNormalWS, in float3 viewDir, in float2 positionSS, out float3 bakeDiffuseLighting, out float3 backBakeDiffuseLighting)
{ EvaluateAdaptiveProbeVolume(posWS, normalWS, backNormalWS, viewDir, positionSS, 0xFFFFFFFF, bakeDiffuseLighting, backBakeDiffuseLighting); }
void EvaluateAdaptiveProbeVolume(in float3 posWS, in float3 normalWS, in float3 viewDir, in float2 positionSS, out float3 bakeDiffuseLighting)
{ EvaluateAdaptiveProbeVolume(posWS, normalWS, viewDir, positionSS, 0xFFFFFFFF, bakeDiffuseLighting); }

// -------------------------------------------------------------
// Reflection Probe Normalization functions
// -------------------------------------------------------------
// Same idea as in Rendering of COD:IW [Drobot 2017]

float EvaluateReflectionProbeSH(float3 sampleDir, float4 reflProbeSHL0L1, float4 reflProbeSHL2_1, float reflProbeSHL2_2)
{
    float outFactor = 0;
    float L0 = reflProbeSHL0L1.x;
    float L1 = dot(reflProbeSHL0L1.yzw, sampleDir);

    outFactor = L0 + L1;

#ifdef PROBE_VOLUMES_L2

    // IMPORTANT: The encoding is unravelled C# side before being sent

    float4 vB = sampleDir.xyzz * sampleDir.yzzx;
    // First 4 coeff.
    float L2 = dot(reflProbeSHL2_1, vB);
    float vC = sampleDir.x * sampleDir.x - sampleDir.y * sampleDir.y;
    L2 += reflProbeSHL2_2 * vC;

    outFactor += L2;
#endif // PROBE_VOLUMES_L2

    return outFactor;
}

float GetReflectionProbeNormalizationFactor(float3 lightingInReflDir, float3 sampleDir, float4 reflProbeSHL0L1, float4 reflProbeSHL2_1, float reflProbeSHL2_2)
{
    float refProbeNormalization = EvaluateReflectionProbeSH(sampleDir, reflProbeSHL0L1, reflProbeSHL2_1, reflProbeSHL2_2);

    float localNormalization = Luminance(real3(lightingInReflDir));
    return lerp(1.f, clamp(SafeDiv(localNormalization, refProbeNormalization), _MinReflProbeNormalizationFactor, _MaxReflProbeNormalizationFactor), _Weight);

}

#endif // __PROBEVOLUME_HLSL__
