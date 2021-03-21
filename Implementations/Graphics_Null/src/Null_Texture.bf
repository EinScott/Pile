using System;

using internal Pile;

namespace Pile
{
	extension Texture
	{
		[SkipCall]
		protected override void ResizeAndClearInternal(uint32 width, uint32 height) {}

		[SkipCall]
		protected override void SetFilter(TextureFilter filter) {}

		[SkipCall]
		protected override void SetWrap(TextureWrap x, TextureWrap y) {}

		[SkipCall]
		protected override void SetData(void* buffer) {}

		[SkipCall]
		protected override void GetData(void* buffer) {}

		public override bool IsFrameBuffer => false;
	}
}
