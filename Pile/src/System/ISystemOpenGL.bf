using System;

namespace Pile
{
	interface ISystemOpenGL
	{
		public abstract class Context
		{
			internal this() {}
			internal ~this() {}

			public abstract void MakeCurrent();
		}

		void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples);
		void* GetGLProcAddress(StringView procName);
		Context GetGLContext();
	}
}
