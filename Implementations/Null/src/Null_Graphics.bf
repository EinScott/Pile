using System;

using internal Pile;

namespace Pile
{
	extension Graphics : IGraphicsOpenGL
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
		protected internal override void Initialize() {}

		[SkipCall]
		protected internal override void Step() {}

		[SkipCall]
		protected internal override void AfterRender() {}

		[SkipCall]
		protected internal override void ClearInternal(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport) {}

		[SkipCall]
		protected internal override void RenderInternal(RenderPass pass) {}

		public IGraphicsOpenGL.GLProfile Profile
		{
			get => .Core;
		}
	}
}
