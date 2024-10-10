using System;
using System.Collections.Generic;
using Unity.Collections;

namespace UnityEngine.Rendering.Universal
{
    /// <summary>
    /// Container class for various data used for shadows in URP.
    /// </summary>
    public class UniversalShadowData : ContextItem
    {
        /// <summary>
        /// True if main light shadows are enabled.
        /// </summary>
        public bool supportsMainLightShadows;

        /// <summary>
        /// True if additional lights shadows are enabled in the URP Asset
        /// </summary>
        internal bool mainLightShadowsEnabled;

        /// <summary>
        /// The width of the main light shadow map.
        /// </summary>
        public int mainLightShadowmapWidth;

        /// <summary>
        /// The height of the main light shadow map.
        /// </summary>
        public int mainLightShadowmapHeight;

        /// <summary>
        /// The number of shadow cascades.
        /// </summary>
        public int mainLightShadowCascadesCount;

        /// <summary>
        /// The split between cascades.
        /// </summary>
        public Vector3 mainLightShadowCascadesSplit;

        /// <summary>
        /// Main light last cascade shadow fade border.
        /// Value represents the width of shadow fade that ranges from 0 to 1.
        /// Where value 0 is used for no shadow fade.
        /// </summary>
        public float mainLightShadowCascadeBorder;

        /// <summary>
        /// True if additional lights shadows are enabled.
        /// </summary>
        public bool supportsAdditionalLightShadows;

        /// <summary>
        /// True if additional lights shadows are enabled in the URP Asset
        /// </summary>
        internal bool additionalLightShadowsEnabled;

        /// <summary>
        /// The width of the additional light shadow map.
        /// </summary>
        public int additionalLightsShadowmapWidth;

        /// <summary>
        /// The height of the additional light shadow map.
        /// </summary>
        public int additionalLightsShadowmapHeight;

        /// <summary>
        /// True if soft shadows are enabled.
        /// </summary>
        public bool supportsSoftShadows;

        /// <summary>
        /// The number of bits used.
        /// </summary>
        public int shadowmapDepthBufferBits;

        public bool supportShadowRamp;
        
        /// <summary>
        /// 用于产生阴影ramp
        /// </summary>
        public Texture2D shadowRampTexture = null;
        
        /// <summary>
        /// A list of shadow bias.
        /// </summary>
        public List<Vector4> bias;

        /// <summary>
        /// A list of resolution for the shadow maps.
        /// </summary>
        public List<int> resolution;

        internal bool isKeywordAdditionalLightShadowsEnabled;
        internal bool isKeywordSoftShadowsEnabled;
        internal int mainLightShadowResolution;
        internal int mainLightRenderTargetWidth;
        internal int mainLightRenderTargetHeight;

        internal NativeArray<URPLightShadowCullingInfos> visibleLightsShadowCullingInfos;
        internal AdditionalLightsShadowAtlasLayout shadowAtlasLayout;

        /// <inheritdoc/>
        public override void Reset()
        {
            supportsMainLightShadows = false;
            mainLightShadowmapWidth = 0;
            mainLightShadowmapHeight = 0;
            mainLightShadowCascadesCount = 0;
            mainLightShadowCascadesSplit = Vector3.zero;
            mainLightShadowCascadeBorder = 0.0f;
            supportsAdditionalLightShadows = false;
            additionalLightsShadowmapWidth = 0;
            additionalLightsShadowmapHeight = 0;
            supportsSoftShadows = false;
            supportShadowRamp = false;
            shadowRampTexture = null;
            shadowmapDepthBufferBits = 0;
            bias?.Clear();
            resolution?.Clear();

            isKeywordAdditionalLightShadowsEnabled = false;
            isKeywordSoftShadowsEnabled = false;
            mainLightShadowResolution = 0;
            mainLightRenderTargetWidth = 0;
            mainLightRenderTargetHeight = 0;

            visibleLightsShadowCullingInfos = default;
            shadowAtlasLayout = default;
        }
        
        public void SetGradientsToRampTexture(Gradient gradient)
        {
            if(supportShadowRamp == false)
                return;
            
            int ramp_width = 128;
            shadowRampTexture = new Texture2D(ramp_width, 1, TextureFormat.RGBAFloat, false);

            for (int x = 0; x < ramp_width; x++)
            {
                Color color = gradient.Evaluate((float)x / (ramp_width - 1));
                shadowRampTexture.SetPixel(x, 0, color);
            }
            shadowRampTexture.Apply();
        }
    }
}
