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

		void* GetGLProcAddress(StringView procName);
		Context GetGLContext();
	}
}
