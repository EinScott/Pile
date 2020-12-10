using System;

using internal Pile;

namespace Pile.Implementations
{
	class BGFX_Texture : Texture.Platform
	{
		internal this(BGFX_Graphics graphics, uint32 width, uint32 height, TextureFormat format)
		{

		}

		protected internal override void ResizeAndClear(uint32 width, uint32 height, TextureFilter filter, TextureWrap wrapX, TextureWrap wrapY)
		{

		}

		protected internal override void SetFilter(TextureFilter filter)
		{

		}

		protected internal override void SetWrap(TextureWrap x, TextureWrap y)
		{

		}

		protected internal override void SetData(void* buffer)
		{

		}

		protected internal override void GetData(void* buffer)
		{

		}

		protected internal override bool IsFrameBuffer()
		{
			return default;
		}
	}
}
