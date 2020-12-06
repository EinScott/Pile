using System;
using Bgfx;

using internal Pile;

namespace Pile.Implementations
{
	class BGFX_Graphics : Graphics
	{
		// Do some more bgfx, then decide which api stuff could be changed
		// - should window not be overridden? (and store window handle)
		// 		-> let wd = new window(); system.init(wd); graphics.init(wd);
		// re-form some things to work better with bgfx, opengl impl. should be fine either way
		// put opengl impl. in different repo?

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
			var platformData = bgfx.PlatformData();
			platformData.ndt = null;
			platformData.nwh = Core.System.GetNativeWindowHandle();

			var init = bgfx.Init();
			init.platformData = platformData;
			init.type = .Count;
			init.resolution.format = bgfx.TextureFormat.RGBA8;
			init.resolution.numBackBuffers = 2;

			init.limits.maxEncoders = 8;
			init.limits.minResourceCbSize = 65536;
			init.limits.transientVbSize = 6291456;
			init.limits.transientIbSize = 2097152;

			bgfx.init(&init);
			return .Ok;
		}

		internal ~this()
		{

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
