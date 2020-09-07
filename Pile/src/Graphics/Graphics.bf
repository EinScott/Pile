using System;

namespace Pile
{
	public abstract class Graphics
	{
		// These must return valid things even BEFORE this is initialized
		// so either static or constructor set
		public abstract uint32 MajorVersion { get; }
		public abstract uint32 MinorVersion { get; }
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

			[Unchecked]ClearInternal(target, flags, color, depth, stencil, clamped);

			return .Ok;
		}

		[Unchecked]
		protected abstract void ClearInternal(RenderTarget target, Clear flags, Color color, float depth, int stencil, Rect viewport);

		public Result<void, String> Render(ref RenderPass pass)
		{
			if (!pass.target.Renderable)
				return .Err("Render Target cannot currently be drawn to");

			if (!(pass.target is FrameBuffer) && !(pass.target is Window))
				return .Err("RenderTarget must be a FrameBuffer or Window");

			if (pass.mesh == null)
				return .Err("Mesh cannot be null");

			if (pass.material == null)
				return .Err("Material cannot be null");

			if (pass.mesh.IndexCount < pass.meshIndexStart + pass.meshIndexCount)
				return .Err("Cannot draw more indices than exist in the Mesh");

			if (pass.viewport != null)
			{
				let size = pass.target.RenderSize;
				let bounds = Rect(0, 0, size.X, size.Y);
				pass.viewport = pass.viewport.Value.OverlapRect(bounds); // Than can be Rect.Zero, should this return or something?
			}

			[Unchecked]RenderInternal(ref pass);
			return .Ok;
		}

		[Unchecked]
		protected abstract void RenderInternal(ref RenderPass pass);

		protected abstract Texture.Platform CreateTexture(int32 width, int32 height, TextureFormat format);
		protected abstract FrameBuffer.Platform CreateFrameBuffer(int32 width, int32 height, TextureFormat[] attachments);
		protected abstract Mesh.Platform CreateMesh();
		protected abstract Shader.Platform CreateShader(ShaderSource source);
	}
}
