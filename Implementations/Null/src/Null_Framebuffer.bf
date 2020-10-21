using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_Framebuffer : FrameBuffer.Platform
	{
		[SkipCall]
		internal override void ResizeAndClear(int32 width, int32 height) {}
	}
}
