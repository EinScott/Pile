using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_Texture : Texture.Platform
	{
		[SkipCall]
		internal override void ResizeAndClear(uint32 width, uint32 height, TextureFilter filter, TextureWrap wrapX, TextureWrap wrapY) {}

		[SkipCall]
		internal override void SetFilter(TextureFilter filter) {}

		[SkipCall]
		internal override void SetWrap(TextureWrap x, TextureWrap y) {}

		[SkipCall]
		internal override void SetData(void* buffer) {}

		[SkipCall]
		internal override void GetData(void* buffer) {}

		internal override bool IsFrameBuffer() => false;
	}
}
