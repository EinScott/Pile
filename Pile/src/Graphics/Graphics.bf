using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class Graphics
	{
		// version has to be set before initialize is called! (may be used by System.Initialize)
		public extern uint32 MajorVersion { get; }
		public extern uint32 MinorVersion { get; }
		public extern String ApiName { get; }
		public extern String Info { get; }

		public int32 MaxTextureSize { get; protected set; }
		public bool OriginBottomLeft { get; protected set; }

		public enum DebugDrawMode { Disabled, WireFrame }
		public extern DebugDrawMode DebugDraw { get; set; }

		internal this() {}
		internal ~this() {}

		protected internal extern void Initialize();
		protected internal extern void Step();
		protected internal extern void AfterRender();

		[Inline]
		public void Clear(IRenderTarget target, Color color) =>
			Clear(target, .Color, color, 0, 0, .(0, 0, target.RenderSize.X, target.RenderSize.Y));

		[Inline]
		public void Clear(IRenderTarget target, Color color, float depth, int stencil) =>
			Clear(target, .All, color, depth, stencil, .(0, 0, target.RenderSize.X, target.RenderSize.Y));

		public void Clear(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{
			Debug.Assert(target.Renderable, "Render Target cannot currently be drawn to");

			let size = target.RenderSize;
			let bounds = Rect(0, 0, size.X, size.Y);
			let clamped = viewport.OverlapRect(bounds);

			ClearInternal(target, flags, color, depth, stencil, clamped);
		}

		protected internal extern void ClearInternal(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport);

		public void Render(RenderPass pass)
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

		protected internal extern void RenderInternal(RenderPass pass);
	}
}
