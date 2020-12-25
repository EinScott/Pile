using System;

using internal Pile;

namespace Pile
{
	extension Texture
	{
		[SkipCall]
		protected internal override void ResizeAndClearInternal(uint32 width, uint32 height) {}

		[SkipCall]
		protected internal override void SetFilter(TextureFilter filter) {}

		[SkipCall]
		protected internal override void SetWrap(TextureWrap x, TextureWrap y) {}

		[SkipCall]
		protected internal override void SetData(void* buffer) {}

		[SkipCall]
		protected internal override void GetData(void* buffer) {}

		public override bool IsFrameBuffer => false;
	}
}
