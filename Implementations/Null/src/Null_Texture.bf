using System;

using internal Pile;

namespace Pile.Implementations
{
	public class Null_Texture : Texture.Platform
	{
		[SkipCall]
		internal override void Initialize(Texture texture) {}

		[SkipCall]
		internal override void ResizeAndClear(int32 width, int32 height) {}

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
