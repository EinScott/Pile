using System;

namespace Pile
{
	public interface ISystemOpenGL
	{
		void* GetGLProcAddress(StringView procName);

		void CreateGLContext();
		//void* GetGLContext();
	}
}
