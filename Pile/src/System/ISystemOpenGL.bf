using System;

namespace Pile
{
	public interface ISystemOpenGL
	{
		public abstract class Context
		{
			protected this()
			{

			}

			public ~this()
			{
				if (!Disposed) Dispose();
			}

			public abstract bool Disposed { get; }
			public abstract void Dispose();
			public abstract void MakeCurrent();
		}

		void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples);
		void* GetGLProcAddress(StringView procName);
		Context GetGLContext();
	}
}
