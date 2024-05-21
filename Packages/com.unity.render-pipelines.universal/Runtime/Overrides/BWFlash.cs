using System;

namespace UnityEngine.Rendering.Universal
{
    [Serializable, VolumeComponentMenu("Post-processing/BW-Flash")]
    [SupportedOnRenderPipeline(typeof(UniversalRenderPipelineAsset))]
    [URPHelpURL("post-processing-bwflash")]
    public class BWFlash : VolumeComponent, IPostProcessComponent
    {

        [Tooltip("dark color.")]
        public ColorParameter darkcolor = new ColorParameter(Color.black, true, false, true);
        
        [Tooltip("light color.")]
        public ColorParameter lightcolor = new ColorParameter(Color.white, true, false, true);

        [Tooltip("Sets the bw center point (screen center is [0.5,0.5]).")]
        public Vector2Parameter center = new Vector2Parameter(new Vector2(0.5f, 0.5f));
        
        [Tooltip("Use the slider to set the strength of the bw.")]
        public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);

        [Tooltip("bw contrast.")]
        public ClampedFloatParameter contrast = new ClampedFloatParameter(1.0f, 0f, 1f);
        
        [Tooltip("bw ratio.")]
        public ClampedFloatParameter ratio = new ClampedFloatParameter(0.1f, 0f, 1f);
        
        [Tooltip("bw reversal")]
        public BoolParameter reversal = new BoolParameter(false);

        /// <inheritdoc/>
        public bool IsActive() => intensity.value > 0f;

        /// <inheritdoc/>
        [Obsolete("Unused #from(2023.1)", false)]
        public bool IsTileCompatible() => true;
    }
}