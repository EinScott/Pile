using System;
using OpenGL43;

namespace Pile.Implementations
{
	public class GL_Texture : Texture.Platform
	{
		uint32 textureID;

		readonly GL_Graphics graphics;
		bool isFrameBuffer;

		Texture texture;
		uint glInternalFormat;
		uint glFormat;
		uint glType;

		private this(GL_Graphics graphics)
		{
			this.graphics = graphics;
		}

		public ~this()
		{
			Delete();
		}

		void Delete()
		{
			if (textureID != 0)
			{
				graphics.[Friend]texturesToDelete.Add(uint32(textureID));
				textureID = 0;
			}
		}

		public override void Initialize(Texture texture)
		{
			this.texture = texture;

			switch (texture.format)
			{
			case .R: glInternalFormat = GL.GL_RED;
			case .RG: glInternalFormat = GL.GL_RG;
			case .RGB: glInternalFormat = GL.GL_RGB;
			case .Color: glInternalFormat = GL.GL_RGBA;
			case .DepthStencil: glInternalFormat = GL.GL_DEPTH24_STENCIL8;
			}

			switch (texture.format)
			{
			case .R: glFormat = GL.GL_RED;
			case .RG: glFormat = GL.GL_RG;
			case .RGB: glFormat = GL.GL_RGB;
			case .Color: glFormat = GL.GL_RGBA;
			case .DepthStencil: glFormat = GL.GL_DEPTH_STENCIL;
			}

			switch (texture.format)
			{
			case .R: glType = GL.GL_UNSIGNED_BYTE;
			case .RG: glType = GL.GL_UNSIGNED_BYTE;
			case .RGB: glType = GL.GL_UNSIGNED_BYTE;
			case .Color: glType = GL.GL_UNSIGNED_BYTE;
			case .DepthStencil: glType = GL.GL_UNSIGNED_INT_24_8;
			}

			// GL create texture
			Create();
		}

		private void Create()
		{
			GL.glGenTextures(1, &textureID);
			Prepare();

			GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, (int)glInternalFormat, texture.Width, texture.Height, 0, glFormat, glType, null);
			int glTexFilter = (int)(texture.Filter == .Nearest ? GL.GL_NEAREST : GL.GL_LINEAR);
			int glTexWrapX = (int)(texture.WrapX == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			int glTexWrapY = (int)(texture.WrapY == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, glTexFilter);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, glTexFilter);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, glTexWrapX);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, glTexWrapY);
		}

		void Prepare()
		{
			GL.glActiveTexture(GL.GL_TEXTURE0);
			GL.glBindTexture(GL.GL_TEXTURE_2D, textureID);
		}

		public override void Resize(int32 width, int32 height)
		{
			Delete();
			Create();
		}

		public override void SetFilter(TextureFilter filter)
		{
			Prepare();
			int glTexFilter = filter == .Nearest ? GL.GL_NEAREST : GL.GL_LINEAR;
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, glTexFilter);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, glTexFilter);

		}

		public override void SetWrap(TextureWrap x, TextureWrap y)
		{
			Prepare();
			int glTexWrapX = (int)(texture.WrapX == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			int glTexWrapY = (int)(texture.WrapY == .Clamp ? GL.GL_CLAMP_TO_EDGE : GL.GL_REPEAT);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, glTexWrapX);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, glTexWrapY);
		}

		public override void SetData(void* buffer)
		{
			Prepare();
			GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, (int)glInternalFormat, texture.Width, texture.Height, 0, glFormat, glType, buffer);
		}

		public override void GetData(void* buffer)
		{
			Prepare();
			GL.glGetTexImage(GL.GL_TEXTURE_2D, 0, glInternalFormat, glType, buffer);
		}

		public override bool IsFrameBuffer() => isFrameBuffer;
	}
}
