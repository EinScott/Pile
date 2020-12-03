using System;
using Bgfx;

using internal Pile;

namespace Pile.Implementations
{
	class BGFX_Graphics : Graphics
	{
		public override uint32 MajorVersion => 0;

		public override uint32 MinorVersion => 0;

		public override String ApiName => "bgfx";

		String info = new String() ~ delete _;
		public override String Info => info;

		// doesnt do anything right now
		DebugDrawMode mode;
		public override DebugDrawMode DebugDraw
		{
			get => mode;
			set => mode = value;
		}

		internal override Result<void> Initialize()
		{
			var init = bgfx.Init();
			bgfx.init(&init);
			return .Ok;
		}

		internal override void Step()
		{

		}

		internal override void AfterRender()
		{

		}

		protected override void ClearInternal(RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{

		}

		protected override void RenderInternal(ref RenderPass pass)
		{

		}

		internal override Texture.Platform CreateTexture(uint32 width, uint32 height, TextureFormat format)
		{
			return default;
		}

		internal override FrameBuffer.Platform CreateFrameBuffer(uint32 width, uint32 height, TextureFormat[] attachments)
		{
			return default;
		}

		internal override Mesh.Platform CreateMesh()
		{
			return default;
		}

		internal override Shader.Platform CreateShader(ShaderData source)
		{
			return default;
		}
	}
}
