using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class GrabScreenFeature : ScriptableRendererFeature
{
    GrabScreenPass m_GrabScreenPass;

    class GrabScreenPass : ScriptableRenderPass
    {
        public GrabScreenPass()
        {
            
        }
        
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {

        }
        
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
        }
        
        public override void FrameCleanup(CommandBuffer cmd)
        {
        }
    }

    /// <inheritdoc/>
    public override void Create()
    {

    }


    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {

    }
}
