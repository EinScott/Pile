using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_Graphics : Graphics, IGraphicsOpenGL
	{
		public override uint32 MajorVersion => 1;
		public override uint32 MinorVersion => 0;
		public override String ApiName => "Null Graphics";
		public override String Info => String.Empty;

		public override DebugDrawMode DebugDraw
		{
			get => .Disabled;

			[SkipCall]
			set {}
		}

		[SkipCall]
		protected internal override Result<void> Initialize() => .Ok;

		[SkipCall]
		protected internal override void Step() {}

		[SkipCall]
		protected internal override void AfterRender() {}

		[SkipCall]
		protected override void ClearInternal(RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport) {}

		[SkipCall]
		protected override void RenderInternal(ref RenderPass pass) {}

		protected internal override Texture.Platform CreateTexture(uint32 width, uint32 height, TextureFormat format)
		{
			return new Null_Texture();
		}

		protected internal override FrameBuffer.Platform CreateFrameBuffer(uint32 width, uint32 height, TextureFormat[] attachments)
		{
			return new Null_Framebuffer();
		}

		protected internal override Mesh.Platform CreateMesh()
		{
			return new Null_Mesh();
		}

		protected internal override Shader.Platform CreateShader(ShaderData source)
		{
			return new Null_Shader();
		}

		public IGraphicsOpenGL.GLProfile Profile
		{
			get => .Core;
		}
	}
}
