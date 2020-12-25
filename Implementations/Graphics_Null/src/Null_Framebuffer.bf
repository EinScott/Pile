using System;

using internal Pile;

namespace Pile
{
	extension FrameBuffer
	{
		[SkipCall]
		protected internal override void ResizeAndClearInternal(uint32 width, uint32 height) {}
	}
}
