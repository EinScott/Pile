using System;

using internal Pile;

namespace Pile.Implementations
{
	class BGFX_Texture : Texture.Platform
	{
		internal this(BGFX_Graphics graphics, uint32 width, uint32 height, TextureFormat format)
		{

		}

		internal override void ResizeAndClear(uint32 width, uint32 height, TextureFilter filter, TextureWrap wrapX, TextureWrap wrapY)
		{

		}

		internal override void SetFilter(TextureFilter filter)
		{

		}

		internal override void SetWrap(TextureWrap x, TextureWrap y)
		{

		}

		internal override void SetData(void* buffer)
		{

		}

		internal override void GetData(void* buffer)
		{

		}

		internal override bool IsFrameBuffer()
		{
			return default;
		}
	}
}
