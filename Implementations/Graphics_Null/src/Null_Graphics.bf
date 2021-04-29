using System;

using internal Pile;

namespace Pile
{
	extension Graphics
	{
		public static override String ApiName => "Null Graphics";
		public static override String Info => String.Empty;

		static this()
		{
			MajorVersion = 1;
			MinorVersion = 0;
			// renderer will default to dummy
		}

		public static override DebugDrawMode DebugDraw
		{
			get => .Disabled;

			[SkipCall]
			set {}
		}

		[SkipCall]
		protected internal static override void Initialize() {}

		[SkipCall]
		protected internal static override void Destroy() {}

		[SkipCall]
		protected internal static override void Step() {}

		[SkipCall]
		protected static override void AfterRenderInternal() {}

		[SkipCall]
		protected static override void ClearInternal(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport) {}

		[SkipCall]
		protected static override void RenderInternal(RenderPass pass) {}

		protected internal override static Shader GetDefaultBatch2dShader()
		{
			return new Shader(scope .("", ""));
		}
	}
}
