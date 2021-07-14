using System;
using OpenGL43;

using internal Pile;

namespace Pile
{
	extension Texture
	{
		internal uint32 textureID;

		internal bool isFrameBuffer;

		GL.InternalFormat glInternalFormat;
		GL.PixelFormat glFormat;
		GL.PixelType glType;

		protected override void Initialize()
		{
			switch (format)
			{
			case .R:
				glInternalFormat = .GL_RED;
				glFormat = .GL_RED;
			case .RG:
				glInternalFormat = .GL_RG;
				glFormat = .GL_RG;
			case .RGB:
				glInternalFormat = .GL_RGB;
				glFormat = .GL_RGB;
			case .Color:
				glInternalFormat = .GL_RGBA;
				glFormat = .GL_RGBA;
			case .DepthStencil:
				glInternalFormat = .GL_DEPTH24_STENCIL8;
				glFormat = .GL_DEPTH_STENCIL;
			}

			switch (format)
			{
			case .R, .RG, .RGB, .Color: glType = .GL_UNSIGNED_BYTE;
			case .DepthStencil: glType = (.)GL.GL_UNSIGNED_INT_24_8;
			}

			// GL create texture
			GLCreate(Width, Height, filter, wrapX, wrapY);
		}

		public ~this()
		{
			GLDelete();
		}

		void GLDelete()
		{
			if (textureID != 0)
			{
				Graphics.texturesToDelete.Add(textureID);
				textureID = 0;
			}
		}

		void GLSetFilter(TextureFilter filter)
		{
			GL.TextureMagFilter glTexFilter = filter == .Nearest ? .GL_NEAREST : .GL_LINEAR;
			GL.TextureMinFilter glMipFilter = filter == .Nearest ? .GL_NEAREST_MIPMAP_NEAREST: .GL_LINEAR_MIPMAP_LINEAR;
			GL.glTexParameteri(.GL_TEXTURE_2D, .GL_TEXTURE_MAG_FILTER, (.)glTexFilter);
			GL.glTexParameteri(.GL_TEXTURE_2D, .GL_TEXTURE_MIN_FILTER, genMipmaps ? (.)glMipFilter : (.)glTexFilter);
		}

		void GLSetWarp(TextureWrap x, TextureWrap y)
		{
			GL.TextureWrapMode glTexWrapX = wrapX == .Clamp ? .GL_CLAMP_TO_EDGE : .GL_REPEAT;
			GL.TextureWrapMode glTexWrapY = wrapY == .Clamp ? .GL_CLAMP_TO_EDGE : .GL_REPEAT;
			GL.glTexParameteri(.GL_TEXTURE_2D, .GL_TEXTURE_WRAP_S, (.)glTexWrapX);
			GL.glTexParameteri(.GL_TEXTURE_2D, .GL_TEXTURE_WRAP_T, (.)glTexWrapY);
		}

		void GLSetData(int32 width, int32 height, void* buffer)
		{
			GL.glTexImage2D(.GL_TEXTURE_2D, 0, glInternalFormat, width, height, 0, glFormat, glType, buffer);
			if (genMipmaps)
				GL.glGenerateMipmap(.GL_TEXTURE_2D);
		}

		void GLCreate(uint32 width, uint32 height, TextureFilter filter, TextureWrap wrapX, TextureWrap wrapY)
		{
			GL.glGenTextures(1, &textureID);
			GL.glBindTexture(.GL_TEXTURE_2D, textureID);
			
			GLSetData((.)width, (.)height, null);
			GLSetFilter(filter);
			GLSetWarp(wrapX, wrapY);

			GL.glBindTexture(.GL_TEXTURE_2D, 0);
		}

		protected override void ResizeAndClearInternal(uint32 width, uint32 height)
		{
			GLDelete();
			GLCreate(width, height, filter, wrapX, wrapY);
		}

		protected override void SetFilter(TextureFilter filter)
		{
			GL.glBindTexture(.GL_TEXTURE_2D, textureID);

			GLSetFilter(filter);

			GL.glBindTexture(.GL_TEXTURE_2D, 0);
		}

		protected override void SetWrap(TextureWrap x, TextureWrap y)
		{
			GL.glBindTexture(.GL_TEXTURE_2D, textureID);

			GLSetWarp(x, y);

			GL.glBindTexture(.GL_TEXTURE_2D, 0);
		}

		protected override void SetData(void* buffer)
		{
			GL.glBindTexture(.GL_TEXTURE_2D, textureID);

			GLSetData((.)Width, (.)Height, buffer);

			GL.glBindTexture(.GL_TEXTURE_2D, 0);
		}

		protected override void GetData(void* buffer)
		{
			GL.glBindTexture(.GL_TEXTURE_2D, textureID);

			GL.glGetTexImage(.GL_TEXTURE_2D, 0, (.)glInternalFormat, glType, buffer);

			GL.glBindTexture(.GL_TEXTURE_2D, 0);
		}

		public override bool IsFrameBuffer => isFrameBuffer;
	}
}
