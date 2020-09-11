using System.Collections;
using System;

namespace Pile
{
	public class FrameBuffer : RenderTarget
	{
		public abstract class Platform
		{
			public readonly List<Texture> Attachments = new List<Texture>() ~ DeleteContainerAndItems!(_);

			public abstract void Resize(int32 width, int32 height);
		}

		readonly Platform platform ~ delete _;

		public int AttachmentCount => platform.Attachments.Count;

		public override Point RenderSize => renderSize;
		Point renderSize;

		public this(int32 width, int32 height)
			: this(width, height, .Color) {}

		public this(int32 width, int32 height, params TextureFormat[] attachments)
		{
			Runtime.Assert(width > 0 || height > 0, "FrameBuffer size must be larger than 0");
			Runtime.Assert(attachments.Count > 0, "FrameBuffer needs at least one attachment");
			renderSize = Point(width, height);
			
			platform = Core.Graphics.[Friend]CreateFrameBuffer(width, height, attachments);
			Renderable = true;
		}

		public Texture this[int index]
		{
			get => platform.Attachments[index];
		}

		public Result<void, String> Resize(int32 width, int32 height)
		{
			if (width <= 0 || height <= 0)
				return .Err("FrameBuffer size must be larger than 0");

			if (renderSize.X != width || renderSize.Y != height)
			{
				renderSize.X = width;
				renderSize.Y = height;

				platform.Resize(width, height);
			}
			return .Ok;
		}

		public static operator Texture(FrameBuffer target) => target.[Friend]platform.Attachments[0];
	}
}
