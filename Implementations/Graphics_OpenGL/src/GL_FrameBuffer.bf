using System;
using OpenGL43;

using internal Pile;

namespace Pile.Implementations
{
	public class GL_FrameBuffer : FrameBuffer.Platform
	{
		readonly GL_Graphics graphics;

		uint32 frameBufferID;

		internal this(GL_Graphics graphics, uint32 width, uint32 height, TextureFormat[] attachments)
		{
			this.graphics = graphics;

			for (int i = 0; i < attachments.Count; i++)
			{
				let attachment = new Texture(width, height, attachments[i]);
				(attachment.platform as GL_Texture).isFrameBuffer = true;
				Attachments.Add(attachment);
			}
		}

		public ~this()
		{
			Delete();
		}

		protected internal override void ResizeAndClear(uint32 width, uint32 height)
		{
			Delete();

			for (int i = 0; i < Attachments.Count; i++)
				Attachments[i].ResizeAndClear(width, height);
		}

		internal void Bind()
		{
			if (frameBufferID == 0)
			{
				GL.glGenFramebuffers(1, &frameBufferID);
				GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, frameBufferID);

				uint color = 0;
				for (let texture in Attachments)
				{
					if (texture.format.IsColorFormat())
					{
						GL.glFramebufferTexture2D(GL.GL_FRAMEBUFFER, GL.GL_COLOR_ATTACHMENT0 + color, GL.GL_TEXTURE_2D, (texture.platform as GL_Texture).textureID, 0);
						color++;
					}
					else
						GL.glFramebufferTexture2D(GL.GL_FRAMEBUFFER, GL.GL_DEPTH_STENCIL_ATTACHMENT, GL.GL_TEXTURE_2D, (texture.platform as GL_Texture).textureID, 0);
				}
			}
			else
				GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, frameBufferID);
		}

		void Delete()
		{
			if (frameBufferID > 0)
			{
				graphics.frameBuffersToDelete.Add(frameBufferID);
				frameBufferID = 0;
			}
		}
	}
}
