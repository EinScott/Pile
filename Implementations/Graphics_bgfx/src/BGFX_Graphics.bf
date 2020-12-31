using System;
using Bgfx;

using internal Pile;

namespace Pile
{
	extension Graphics
	{
		// Do some more bgfx, then decide which api stuff could be changed
		// - should window not be overridden? (and store window handle) NO IS FINE
		// 		-> let wd = new window(); system.init(wd); graphics.init(wd); (NAH, system needs to control it)
		// overriding is probably still a good idea. Maybe add a platform to it finally, same with input
		// but having window more integrated with graphics would still be good

		// re-form some things to work better with bgfx, opengl impl. should be fine either way
		// put opengl impl. in different repo?

		// tests for system.glGraphics in sld impl shouldnt be there
		// have rendererBackend enum for graphics to test that instead

		// try to remove interfaces IOpenGLGraphics/System
		// would be nicer if the graphics just called a func on system to see if they are compatible
		// - probably you wouldnt need to ever get the glcontext publicly. try to solve that differently?

		public override uint32 MajorVersion => 1;

		public override uint32 MinorVersion => 0;

		public override String ApiName => "bgfx";

		String info = new String() ~ delete _;
		public override String Info => info;

		// doesnt do anything right now
		DebugDrawMode mode;
		public override DebugDrawMode DebugDraw
		{
			get => mode;
			set => mode = value; // set_debug
		}

		protected internal override void Initialize()
		{
			Core.Window.OnResized.Add(new => Resized);

			var platformData = bgfx.PlatformData();
			platformData.ndt = null;
			platformData.nwh = Core.System.GetNativeWindowHandle(); // todo: This should be in WINDOW? (Cleanup this api between Graphics and System A LOT)
			bgfx.render_frame(0);

			var init = bgfx.Init();
			init.platformData = platformData;
			init.type = .Count;
			init.resolution.format = bgfx.TextureFormat.RGBA8;
			init.resolution.numBackBuffers = 2;
			init.resolution.width = (uint32)Core.Window.RenderSize.X;
			init.resolution.height = (uint32)Core.Window.RenderSize.Y;
			init.resolution.reset = (uint32)Core.Window.VSync;

			init.limits.maxEncoders = 8;
			init.limits.minResourceCbSize = 65536;
			init.limits.transientVbSize = 6291456;
			init.limits.transientIbSize = 2097152;

			if (!bgfx.init(&init))
				Core.FatalError("bgfx.init failed.");

			let caps = bgfx.get_caps();

			if (caps.originBottomLeft > 0)
				OriginBottomLeft = true;

			info.AppendF("renderer: {}, vendor: {}, deviceID", caps.rendererType, (bgfx.PciIdFlags)caps.vendorId, caps.deviceId);
		}

		void Resized()
		{
			let rendSize = Core.Window.RenderSize; // TODO: not checking for vsync chage!!
			bgfx.reset((uint32)rendSize.X, (uint32)rendSize.Y, (uint32)Core.Window.VSync, bgfx.TextureFormat.Count);
		}

		/*internal ~this()
		{

		}*/

		protected internal override void Step()
		{

		}

		protected internal override void AfterRender()
		{
			bgfx.frame(false);
		}

		protected internal override void ClearInternal(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{

		}

		protected internal override void RenderInternal(RenderPass pass)
		{

		}
	}
}
