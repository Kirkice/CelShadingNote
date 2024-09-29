using System;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Experimental.Rendering;

namespace UnityEngine.Rendering.Universal.Internal
{
    public class GrabScreenPass : ScriptableRenderPass
    {
        Material m_CopyColorMaterial;
        private RTHandle source { get; set; }
        private RTHandle destination { get; set; }

        private PassData m_PassData;

        public GrabScreenPass(RenderPassEvent evt, Material copyColorMaterial = null, string customPassName = null)
        {
            base.profilingSampler = customPassName != null
                ? new ProfilingSampler(customPassName)
                : new ProfilingSampler(nameof(GrabScreenPass));
            m_PassData = new PassData();

            m_CopyColorMaterial = copyColorMaterial;
            renderPassEvent = evt;
            base.useNativeRenderPass = false;
        }

        /// <summary>
        /// Get a descriptor and filter mode for the required texture for this pass
        /// </summary>
        /// <param name="downsamplingMethod"></param>
        /// <param name="descriptor"></param>
        /// <param name="filterMode"></param>
        /// <seealso cref="Downsampling"/>
        /// <seealso cref="RenderTextureDescriptor"/>
        /// <seealso cref="FilterMode"/>
        public static void ConfigureDescriptor(ref RenderTextureDescriptor descriptor)
        {
            descriptor.msaaSamples = 1;
            descriptor.depthBufferBits = 0;
            descriptor.width /= 4;
            descriptor.height /= 4;
        }
        
        /// <summary>
        /// Configure the pass with the source and destination to execute on.
        /// </summary>
        /// <param name="source">Source render target.</param>
        /// <param name="destination">Destination render target.</param>
        /// <param name="downsampling">The downsampling method to use.</param>
        [Obsolete("Use RTHandles for source and destination.", true)]
        public void Setup(RenderTargetIdentifier source, RenderTargetHandle destination)
        {
            throw new NotSupportedException(
                "Setup with RenderTargetIdentifier has been deprecated. Use it with RTHandles instead.");
        }

        /// <summary>
        /// Configure the pass with the source and destination to execute on.
        /// </summary>
        /// <param name="source">Source render target.</param>
        /// <param name="destination">Destination render target.</param>
        /// <param name="downsampling">The downsampling method to use.</param>
        public void Setup(RTHandle source, RTHandle destination)
        {
            this.source = source;
            this.destination = destination;
        }

        [Obsolete(DeprecationMessage.CompatibilityScriptingAPIObsolete, false)]
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            cmd.SetGlobalTexture(destination.name, destination.nameID);
        }

        /// <inheritdoc/>
        [Obsolete(DeprecationMessage.CompatibilityScriptingAPIObsolete, false)]
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            m_PassData.copyColorMaterial = m_CopyColorMaterial;

            var cmd = renderingData.commandBuffer;

            // TODO RENDERGRAPH: Do we need a similar check in the RenderGraph path?
            //It is possible that the given color target is now the frontbuffer
            if (source == renderingData.cameraData.renderer.GetCameraColorFrontBuffer(cmd))
            {
                source = renderingData.cameraData.renderer.cameraColorTargetHandle;
            }

#if ENABLE_VR && ENABLE_XR_MODULE
            if (renderingData.cameraData.xr.supportsFoveatedRendering)
                cmd.SetFoveatedRenderingMode(FoveatedRenderingMode.Disabled);
#endif
            ScriptableRenderer.SetRenderTarget(cmd, destination, k_CameraTarget, clearFlag, clearColor);
            ExecutePass(CommandBufferHelpers.GetRasterCommandBuffer(cmd), m_PassData, source,
                renderingData.cameraData.xr.enabled);
        }

        private static void ExecutePass(RasterCommandBuffer cmd, PassData passData, RTHandle source,
            bool useDrawProceduralBlit)
        {
            var copyColorMaterial = passData.copyColorMaterial;

            using (new ProfilingScope(cmd, ProfilingSampler.Get(URPProfileId.GrabScreen)))
            {
                Vector2 viewportScale = source.useScaling
                    ? new Vector2(source.rtHandleProperties.rtHandleScale.x, source.rtHandleProperties.rtHandleScale.y)
                    : Vector2.one;
                Blitter.BlitTexture(cmd, source, viewportScale, copyColorMaterial, 0);
            }
        }

        private class PassData
        {
            internal TextureHandle source;

            internal TextureHandle destination;

            // internal RenderingData renderingData;
            internal bool useProceduralBlit;
            internal Material copyColorMaterial;
        }

        internal TextureHandle Render(RenderGraph renderGraph, ContextContainer frameData,
            out TextureHandle destination, in TextureHandle source)
        {
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();
            RenderTextureDescriptor descriptor = cameraData.cameraTargetDescriptor;
            ConfigureDescriptor( ref descriptor);

            destination = UniversalRenderer.CreateRenderGraphTexture(renderGraph, descriptor, "_CameraOpaqueTexture",
                true, FilterMode.Bilinear);

            RenderInternal(renderGraph, destination, source, "Grab Screen", cameraData.xr.enabled);

            return destination;
        }

        // This will not create a new texture, but will reuse an existing one as destination.
        // Typical use case is a persistent texture imported to the render graph. For example history textures.
        // Note that the amount of downsampling is determined by the destination size.
        // Therefore, the downsampling param controls only the algorithm (shader) used for the downsampling, not size.
        internal void RenderToExistingTexture(RenderGraph renderGraph, ContextContainer frameData,
            in TextureHandle destination, in TextureHandle source,
            string passName = "Grab Screen")
        {
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();
            RenderInternal(renderGraph, destination, source, passName, cameraData.xr.enabled);
        }

        private void RenderInternal(RenderGraph renderGraph, in TextureHandle destination, in TextureHandle source,
            string passName, bool useProceduralBlit)
        {
            using (var builder =
                   renderGraph.AddRasterRenderPass<PassData>(passName, out var passData, base.profilingSampler))
            {
                passData.destination = destination;
                builder.SetRenderAttachment(destination, 0, AccessFlags.Write);
                passData.source = source;
                builder.UseTexture(source, AccessFlags.Read);
                passData.useProceduralBlit = useProceduralBlit;
                passData.copyColorMaterial = m_CopyColorMaterial;

                if (destination.IsValid())
                    builder.SetGlobalTextureAfterPass(destination, Shader.PropertyToID("_CameraScreenTexture"));

                // TODO RENDERGRAPH: culling? force culling off for testing
                builder.AllowPassCulling(false);

                builder.SetRenderFunc((PassData data, RasterGraphContext context) =>
                {
                    ExecutePass(context.cmd, data, data.source, data.useProceduralBlit);
                });
            }
        }
    }
}