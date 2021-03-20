using System.Collections;
using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class FrameBuffer : IRenderTarget
	{
		readonly List<Texture> Attachments = new List<Texture>() ~ DeleteContainerAndItems!(_);

		public int AttachmentCount => Attachments.Count;

		bool renderable;
		public bool Renderable => renderable;
		
		UPoint2 renderSize;
		public UPoint2 RenderSize => renderSize;

		public this(uint32 width, uint32 height)
			: this(width, height, .Color) {}

		public this(uint32 width, uint32 height, params TextureFormat[] attachments)
		{
			Debug.Assert(Core.run, "Core needs to be initialized before creating platform dependent objects");

			Debug.Assert(width > 0 && height > 0, "FrameBuffer size must be larger than 0");
			Debug.Assert(attachments.Count > 0, "FrameBuffer needs at least one attachment");
			renderSize = UPoint2(width, height);

			Initialize(width, height, attachments);

			renderable = true;
		}

		public Texture this[int index]
		{
			get => Attachments[index];
		}

		public void ResizeAndClear(uint32 width, uint32 height)
		{
			Debug.Assert(width > 0 && height > 0, "FrameBuffer size must be larger that 0");

			if (renderSize.X != width || renderSize.Y != height)
			{
				renderSize.X = width;
				renderSize.Y = height;

				ResizeAndClearInternal(width, height);
			}
		}

		protected internal extern void Initialize(uint32 width, uint32 height, TextureFormat[] attachments);
		protected internal extern void ResizeAndClearInternal(uint32 width, uint32 height);

		public static operator Texture(FrameBuffer target) => target.Attachments[0];
	}
}
