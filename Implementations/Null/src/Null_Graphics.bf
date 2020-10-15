using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_Graphics : Graphics, IGraphicsOpenGL
	{
		public override uint32 MajorVersion => 0;

		public override uint32 MinorVersion => 0;

		public override System.String ApiName => "Null Graphics";

		public override System.String DeviceName => "Unknown";

		public override DebugDrawMode DebugDraw
		{
			get => .Disabled;

			[SkipCall]
			set {}
		}

		[SkipCall]
		internal override Result<void> Initialize() => .Ok;

		[SkipCall]
		internal override void Step() {}

		[SkipCall]
		internal override void AfterRender() {}

		[SkipCall]
		[Unchecked] // If this is not given, beef will not count this method as overridden!
		protected override void ClearInternal(RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport) {}

		[SkipCall]
		[Unchecked]
		protected override void RenderInternal(ref RenderPass pass) {}

		internal override Texture.Platform CreateTexture(int32 width, int32 height, TextureFormat format)
		{
			return new Null_Texture();
		}

		internal override FrameBuffer.Platform CreateFrameBuffer(int32 width, int32 height, TextureFormat[] attachments)
		{
			return new Null_Framebuffer();
		}

		internal override Mesh.Platform CreateMesh()
		{
			return new Null_Mesh();
		}

		internal override Shader.Platform CreateShader(ShaderData source)
		{
			return new Null_Shader();
		}

		public IGraphicsOpenGL.GLProfile Profile
		{
			get => .Core;
		}
	}
}
