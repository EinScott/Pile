using System;

using internal Pile;

namespace Pile
{
	public abstract class Graphics
	{
		// version has to be set before initialize is called! (may be used by System.Initialize)
		public abstract uint32 MajorVersion { get; }
		public abstract uint32 MinorVersion { get; }
		public abstract String ApiName { get; }
		public abstract String Info { get; }

		public int32 MaxTextureSize { get; protected set; }
		public bool OriginBottomLeft { get; protected set; }

		public enum DebugDrawMode { Disabled, WireFrame }
		public abstract DebugDrawMode DebugDraw { get; set; }

		internal this() {}
		internal ~this() {}

		protected internal abstract void Initialize();
		protected internal abstract void Step();
		protected internal abstract void AfterRender();

		public Result<void> Clear(IRenderTarget target, Color color) =>
			Clear(target, .Color, color, 0, 0, .(0, 0, target.RenderSize.X, target.RenderSize.Y));

		public Result<void> Clear(IRenderTarget target, Color color, float depth, int stencil) =>
			Clear(target, .All, color, depth, stencil, .(0, 0, target.RenderSize.X, target.RenderSize.Y));

		public Result<void> Clear(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{
			if (!target.Renderable)
				LogErrorReturn!("Target cannot currently be rendered to");

			let size = target.RenderSize;
			let bounds = Rect(0, 0, size.X, size.Y);
			let clamped = viewport.OverlapRect(bounds);

			ClearInternal(target, flags, color, depth, stencil, clamped);

			return .Ok;
		}

		protected abstract void ClearInternal(IRenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport);

		public Result<void> Render(ref RenderPass pass)
		{
			if (!pass.target.Renderable)
				LogErrorReturn!("Render Target cannot currently be drawn to");

			if (!(pass.target is FrameBuffer) && !(pass.target is Window))
				LogErrorReturn!("RenderTarget must be a FrameBuffer or Window");

			if (pass.mesh == null)
				LogErrorReturn!("Mesh cannot be null");

			if (pass.material == null)
				LogErrorReturn!("Material cannot be null");

			if (pass.mesh.IndexCount < pass.meshIndexStart + pass.meshIndexCount)
				LogErrorReturn!("Cannot draw more indices than exist in the Mesh");

			if (pass.viewport != null)
			{
				let size = pass.target.RenderSize;
				let bounds = Rect(0, 0, size.X, size.Y);
				pass.viewport = pass.viewport.Value.OverlapRect(bounds);
			}

			RenderInternal(ref pass);
			return .Ok;
		}

		protected abstract void RenderInternal(ref RenderPass pass);

		protected internal abstract Texture.Platform CreateTexture(uint32 width, uint32 height, TextureFormat format);
		protected internal abstract FrameBuffer.Platform CreateFrameBuffer(uint32 width, uint32 height, TextureFormat[] attachments);
		protected internal abstract Mesh.Platform CreateMesh();
		protected internal abstract Shader.Platform CreateShader(ShaderData source);
	}
}
