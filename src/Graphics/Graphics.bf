using System;

namespace Pile
{
	public abstract class Graphics
	{
		// These must return valid things even BEFORE this is initialized
		public abstract int32 MajorVersion { get; }
		public abstract int32 MinorVersion { get; }
		public abstract String ApiName { get; }
		public abstract String DeviceName { get; }

		public int32 MaxTextureSize { get; protected set; }
		public bool OriginBottomLeft { get; protected set; }

		protected abstract Result<void, String> Initialize();
		protected abstract void Update();
		protected abstract void AfterRender();

		public Result<void, String> Clear(RenderTarget target, Color color) =>
			Clear(target, .Color, color, 0, 0, .(0, 0, target.RenderSize.X, target.RenderSize.Y));

		public Result<void, String> Clear(RenderTarget target, Color color, float depth, int stencil) =>
			Clear(target, .All, color, depth, stencil, .(0, 0, target.RenderSize.X, target.RenderSize.Y));

		public Result<void, String> Clear(RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport)
		{
			if (!target.Renderable)
				return .Err("Target cannot currently be rendered to");

			let size = target.RenderSize;
			let bounds = Rect(0, 0, size.X, size.Y);
			let clamped = viewport.OverlapRect(bounds);

			ClearInternal(target, flags, color, depth, stencil, clamped);

			return .Ok;
		}

		protected abstract void ClearInternal(RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport);

		public Result<void, String> Render(ref RenderPass pass)
		{
			if (!pass.target.Renderable)
				return .Err("Render Target cannot currently be drawn to");

			if (!(pass.target is FrameBuffer) && !(pass.target is Window))
				return .Err("RenderTarget must be a FrameBuffer or Window");

			
			return .Ok;
		}

		protected abstract void RenderInternal(ref RenderPass pass);

		protected abstract Texture.Platform CreateTexture(int32 width, int32 height, TextureFormat format);
		protected abstract Mesh.Platform CreateMesh();
		protected abstract Shader.Platform CreateShader(ShaderSource source);
		// ...
	}
}
