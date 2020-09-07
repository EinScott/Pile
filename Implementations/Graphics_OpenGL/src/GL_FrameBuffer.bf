using System;
using OpenGL43;

namespace Pile.Implementations
{
	public class GL_FrameBuffer : FrameBuffer.Platform
	{
		readonly GL_Graphics graphics;

		uint32 frameBufferID;

		private this(GL_Graphics graphics, int32 width, int32 height, TextureFormat[] attachments)
		{
			this.graphics = graphics;

			for (int i = 0; i < attachments.Count; i++)
			{
				let attachment = new Texture(width, height, attachments[i]);
				(attachment.[Friend]platform as GL_Texture).[Friend]isFrameBuffer = true;
				Attachments.Add(attachment);
			}
		}

		public ~this()
		{
			Delete();
		}

		public override void Resize(int32 width, int32 height)
		{
			Delete();

			for (int i = 0; i < Attachments.Count; i++)
				Attachments[i].Resize(width, height);
		}

		public void Bind()
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
						GL.glFramebufferTexture2D(GL.GL_FRAMEBUFFER, GL.GL_COLOR_ATTACHMENT0 + color, GL.GL_TEXTURE_2D, (texture.[Friend]platform as GL_Texture).[Friend]textureID, 0);
						color++;
					}
					else
						GL.glFramebufferTexture2D(GL.GL_FRAMEBUFFER, GL.GL_DEPTH_STENCIL_ATTACHMENT, GL.GL_TEXTURE_2D, (texture.[Friend]platform as GL_Texture).[Friend]textureID, 0);
				}
			}
			else
				GL.glBindFramebuffer(GL.GL_FRAMEBUFFER, frameBufferID);
		}

		void Delete()
		{
			if (frameBufferID > 0)
			{
				graphics.[Friend]frameBuffersToDelete.Add(frameBufferID);
				frameBufferID = 0;
			}
		}
	}
}
