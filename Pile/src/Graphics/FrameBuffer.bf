using System.Collections;
using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class FrameBuffer : RenderTarget
	{
		protected internal abstract class Platform
		{
			internal readonly List<Texture> Attachments = new List<Texture>() ~ DeleteContainerAndItems!(_);
			protected internal abstract void ResizeAndClear(uint32 width, uint32 height);
		}

		internal readonly Platform platform ~ delete _;

		public int AttachmentCount => platform.Attachments.Count;

		public override UPoint2 RenderSize => renderSize;
		UPoint2 renderSize;

		public this(uint32 width, uint32 height)
			: this(width, height, .Color) {}

		public this(uint32 width, uint32 height, params TextureFormat[] attachments)
		{
			Debug.Assert(Core.Graphics != null, "Core needs to be initialized before creating platform dependant objects");

			Debug.Assert(width > 0 || height > 0, "FrameBuffer size must be larger than 0");
			Debug.Assert(attachments.Count > 0, "FrameBuffer needs at least one attachment");
			renderSize = UPoint2(width, height);
			
			platform = Core.Graphics.CreateFrameBuffer(width, height, attachments);
			Renderable = true;
		}

		public Texture this[int index]
		{
			get => platform.Attachments[index];
		}

		public Result<void> ResizeAndClear(uint32 width, uint32 height)
		{
			if (width <= 0 || height <= 0)
				LogErrorReturn!("FrameBuffer size must be larger than 0");

			if (renderSize.X != width || renderSize.Y != height)
			{
				renderSize.X = width;
				renderSize.Y = height;

				platform.ResizeAndClear(width, height);
			}
			return .Ok;
		}

		public static operator Texture(FrameBuffer target) => target.platform.Attachments[0];
	}
}
