using System;

namespace Pile
{
	public interface ISystemOpenGL
	{
		/*public abstract class Context : IDisposable
		{
			public abstract bool IsDisposed { get; }

			public abstract void Dispose();
		}*/

		void* GetGLProcAddress(StringView procName);

		void CreateGLContext();
		//void* GetGLContext();
	}
}
