using System;
using OpenGL43;

using internal Pile;

namespace Pile
{
	extension Texture
	{
		internal uint32 textureID;

		internal bool isFrameBuffer;

		uint glInternalFormat;
		uint glFormat;
		uint glType;

		protected override void Initialize()
		{
			switch (format)
			{
			case .R: glInternalFormat = glFormat = GL.GL_RED;
			case .RG: glInternalFormat = glFormat = GL.GL_RG;
			case .RGB: glInternalFormat = glFormat = GL.GL_RGB;
			case .Color: glInternalFormat = glFormat = GL.GL_RGBA;
			case .DepthStencil:
				glInternalFormat = GL.GL_DEPTH24_STENCIL8;
				glFormat = GL.GL_DEPTH_STENCIL;
			}

			switch (format)
			{
			case .R, .RG, .RGB, .Color: glType = GL.GL_UNSIGNED_BYTE;
			case .DepthStencil: glType = GL.GL_UNSIGNED_INT_24_8;
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
			int glTexFilter = (int)(filter == .Nearest ? GL.GL_NEAREST : GL.GL_LINEAR);
			int glMipFilter = (int)(filter == .Nearest ? GL.GL_NEAREST_MIPMAP_NEAREST: GL.GL_LINEAR_MIPMAP_LINEAR);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, glTexFilter);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, genMipmaps ? glMipFilter : glTexFilter);
		}

		void GLSetWarp(TextureWrap x, TextureWrap y)
		{
			int glTexWrapX = (int)(wrapX == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			int glTexWrapY = (int)(wrapY == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, glTexWrapX);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, glTexWrapY);
		}

		void GLSetData(int width, int height, void* buffer)
		{
			GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, (int)glInternalFormat, width, height, 0, glFormat, glType, buffer);
			if (genMipmaps)
				GL.glGenerateMipmap(GL.GL_TEXTURE_2D);
		}

		void GLCreate(uint32 width, uint32 height, TextureFilter filter, TextureWrap wrapX, TextureWrap wrapY)
		{
			GL.glGenTextures(1, &textureID);
			GL.glBindTexture(GL.GL_TEXTURE_2D, textureID);
			
			GLSetData(width, height, null);
			GLSetFilter(filter);
			GLSetWarp(wrapX, wrapY);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		protected override void ResizeAndClearInternal(uint32 width, uint32 height)
		{
			GLDelete();
			GLCreate(width, height, filter, wrapX, wrapY);
		}

		protected override void SetFilter(TextureFilter filter)
		{
			GL.glBindTexture(GL.GL_TEXTURE_2D, textureID);

			GLSetFilter(filter);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		protected override void SetWrap(TextureWrap x, TextureWrap y)
		{
			GL.glBindTexture(GL.GL_TEXTURE_2D, textureID);

			GLSetWarp(x, y);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		protected override void SetData(void* buffer)
		{
			GL.glBindTexture(GL.GL_TEXTURE_2D, textureID);

			GLSetData(Width, Height, buffer);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		protected override void GetData(void* buffer)
		{
			GL.glBindTexture(GL.GL_TEXTURE_2D, textureID);

			GL.glGetTexImage(GL.GL_TEXTURE_2D, 0, glInternalFormat, glType, buffer);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		public override bool IsFrameBuffer => isFrameBuffer;
	}
}
