using System;

namespace Pile
{
	public class Shader
	{
		public class Platform
		{

		}

		readonly Platform platform;

		public this(ShaderSource source)
		{
			platform = Core.Graphics.[Friend]CreateShader(source);

		}

		public ~this()
		{
			delete platform;
		}
	}
}
