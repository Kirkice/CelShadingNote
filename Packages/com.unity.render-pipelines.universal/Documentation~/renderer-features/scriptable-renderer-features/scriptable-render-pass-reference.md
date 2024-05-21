## Scriptable Render Pass Compatibility Mode API reference 

You can use the following methods within a Scriptable Render Pass to handle its core functions, if you enable **Compatibility Mode (Render Graph Disabled)** in [URP graphics settings](../../urp-global-settings.md).

> **Note**: Unity no longer develops or improves the rendering path that doesn't use the render graph API. Use the render graph API instead when developing new graphics features.

| **Method** | **Description** |
| ---------- | --------------- |
| `Execute` | Use this method to implement the rendering logic for the Scriptable Renderer Feature.<br/><br/>**Note**: You must not call `ScriptableRenderContext.Submit` on a command buffer provided by URP. The render pipeline handles this at specific points in the pipeline. |
| `OnCameraCleanup` | Use this method to clean up any resources that were allocated during the render pass. |
| `OnCameraSetup` | Use this method to configure render targets and their clear state. You can also use it to create temporary render target textures.<br/><br/>**Note**: When this method is empty, the render pass renders to the active camera render target. |

## Additional resources

* [Scriptable Render Passes](../intro-to-scriptable-render-passes.md)
* [How to create a Custom Renderer Feature](../create-custom-renderer-feature.md)
