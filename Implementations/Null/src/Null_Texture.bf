using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_Texture : Texture.Platform
	{
		[SkipCall]
		protected internal override void ResizeAndClear(uint32 width, uint32 height, TextureFilter filter, TextureWrap wrapX, TextureWrap wrapY) {}

		[SkipCall]
		protected internal override void SetFilter(TextureFilter filter) {}

		[SkipCall]
		protected internal override void SetWrap(TextureWrap x, TextureWrap y) {}

		[SkipCall]
		protected internal override void SetData(void* buffer) {}

		[SkipCall]
		protected internal override void GetData(void* buffer) {}

		protected internal override bool IsFrameBuffer() => false;
	}
}
