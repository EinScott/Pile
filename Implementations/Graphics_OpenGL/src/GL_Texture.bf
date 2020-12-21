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

		protected internal override void Initialize()
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
			Create(Width, Height, filter, wrapX, wrapY);
		}

		public ~this()
		{
			Delete();
		}

		void Delete()
		{
			if (textureID != 0)
			{
				Core.Graphics.texturesToDelete.Add(textureID);
				textureID = 0;
			}
		}

		private void Create(uint32 width, uint32 height, TextureFilter filter, TextureWrap wrapX, TextureWrap wrapY)
		{
			GL.glGenTextures(1, &textureID);
			Prepare();

			// TODO: optional mipmaps?
			GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, (int)glInternalFormat, width, height, 0, glFormat, glType, null);
			int glTexFilter = (int)(filter == .Nearest ? GL.GL_NEAREST : GL.GL_LINEAR);
			int glTexWrapX = (int)(wrapX == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			int glTexWrapY = (int)(wrapY == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, glTexFilter);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, glTexFilter);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, glTexWrapX);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, glTexWrapY);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		void Prepare()
		{
			GL.glActiveTexture(GL.GL_TEXTURE0);
			GL.glBindTexture(GL.GL_TEXTURE_2D, textureID);
		}

		protected internal override void ResizeAndClearInternal(uint32 width, uint32 height)
		{
			Delete();
			Create(width, height, filter, wrapX, wrapY);
		}

		protected internal override void SetFilter(TextureFilter filter)
		{
			Prepare();
			int glTexFilter = filter == .Nearest ? GL.GL_NEAREST : GL.GL_LINEAR;
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, glTexFilter);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, glTexFilter);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);

		}

		protected internal override void SetWrap(TextureWrap x, TextureWrap y)
		{
			Prepare();
			int glTexWrapX = (int)(x == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			int glTexWrapY = (int)(y == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, glTexWrapX);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, glTexWrapY);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		protected internal override void SetData(void* buffer)
		{
			Prepare();
			GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, (int)glInternalFormat, Width, Height, 0, glFormat, glType, buffer);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		protected internal override void GetData(void* buffer)
		{
			Prepare();
			GL.glGetTexImage(GL.GL_TEXTURE_2D, 0, glInternalFormat, glType, buffer);

			GL.glBindTexture(GL.GL_TEXTURE_2D, 0);
		}

		public override bool IsFrameBuffer => isFrameBuffer;
	}
}
