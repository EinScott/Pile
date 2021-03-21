using System;

namespace Pile
{
	enum Renderer
	{
		case Dummy = 0;
		case OpenGLCore;
		case OpenGLES;
		case Vulkan;
		case Direct3D;
		case Metal;

		[Inline]
		public bool IsOpenGL => this == .OpenGLCore || this == .OpenGLES;
	}
}
