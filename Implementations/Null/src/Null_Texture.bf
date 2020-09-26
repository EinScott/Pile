using System;

namespace Pile.Implementations
{
	public class Null_Texture : Texture.Platform
	{
		[SkipCall]
		public override void Initialize(Texture texture) {}

		[SkipCall]
		public override void Resize(int32 width, int32 height) {}

		[SkipCall]
		public override void SetFilter(TextureFilter filter) {}

		[SkipCall]
		public override void SetWrap(TextureWrap x, TextureWrap y) {}

		[SkipCall]
		public override void SetData(void* buffer) {}

		[SkipCall]
		public override void GetData(void* buffer) {}

		public override bool IsFrameBuffer() => false;
	}
}
