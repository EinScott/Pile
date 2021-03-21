using System;

using internal Pile;

namespace Pile
{
	extension FrameBuffer
	{
		[SkipCall]
		protected override void Initialize(uint32 width, uint32 height, Pile.TextureFormat[] attachments) {}

		[SkipCall]
		protected override void ResizeAndClearInternal(uint32 width, uint32 height) {}
	}
}
