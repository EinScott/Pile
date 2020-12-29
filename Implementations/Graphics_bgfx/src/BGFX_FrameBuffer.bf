using System;

using internal Pile;

namespace Pile
{
	extension FrameBuffer
	{
		protected internal override void Initialize(uint32 width, uint32 height, TextureFormat[] attachments)
		{
			Attachments.Count = attachments.Count;
			for (int i = 0; i < attachments.Count; i++)
			{
				let attachment = new Texture(width, height, attachments[i]);
				//attachment.isFrameBuffer = true;
				Attachments[i] = attachment;
			}
		}

		protected internal override void ResizeAndClearInternal(uint32 width, uint32 height)
		{

		}
	}
}
