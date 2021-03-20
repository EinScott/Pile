using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	[StaticInitPriority(PILE_SINIT_IMPL)]
	static class Graphics
	{
		public static readonly uint32 MajorVersion;
		public static readonly uint32 MinorVersion;
		public static readonly Renderer Renderer;

		public static extern String ApiName { get; }
		public static extern String Info { get; }

		public static int32 MaxTextureSize { get; protected set; }
		public static bool OriginBottomLeft { get; protected set; }

		public enum DebugDrawMode { Disabled, WireFrame }
		public static extern DebugDrawMode DebugDraw { get; set; }

		protected internal static extern void Initialize();
		protected internal static extern void Step();
		protected internal static extern void AfterRender();

		[Inline]
		public static void Clear(IRenderTarget target, Color color) =>
			Clear(target, .Color, color, 0, 0, .(0, 0, target.RenderSize.X, target.RenderSize.Y));

		[Inline]
		public static void Clear(IRenderTarget target, Color color, float depth, int stencil) =>
			Clear(target, .All, color, depth, stencil, .(0, 0, target.RenderSize.X, target.RenderSize.Y));

		public static void Clear(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{
			Debug.Assert(target.Renderable, "Render Target cannot currently be drawn to");

			let size = target.RenderSize;
			let bounds = Rect(0, 0, size.X, size.Y);
			let clamped = viewport.OverlapRect(bounds);

			ClearInternal(target, flags, color, depth, stencil, clamped);
		}

		protected internal static extern void ClearInternal(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport);

		public static void Render(RenderPass pass)
		{
			var pass;

			Debug.Assert(pass.target.Renderable, "Render Target cannot currently be drawn to");
			Debug.Assert((pass.target is FrameBuffer) || (pass.target is Window), "RenderTarget must be a FrameBuffer or Window");
			Debug.Assert(pass.mesh != null && pass.material != null, "Mesh and Material cannot be null");
			Debug.Assert(pass.mesh.IndexCount >= pass.meshIndexStart + pass.meshIndexCount, "Cannot draw more indices than exist in the Mesh");

			if (pass.viewport != null)
			{
				let size = pass.target.RenderSize;
				let bounds = Rect(0, 0, size.X, size.Y);
				pass.viewport = pass.viewport.Value.OverlapRect(bounds);
			}

			RenderInternal(pass);
		}

		protected internal static extern void RenderInternal(RenderPass pass);
	}
}
