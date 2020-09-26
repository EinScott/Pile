using System;

namespace Pile.Implementations
{
	public class Null_Framebuffer : FrameBuffer.Platform
	{
		[SkipCall]
		public override void Resize(int32 width, int32 height) {}
	}
}
