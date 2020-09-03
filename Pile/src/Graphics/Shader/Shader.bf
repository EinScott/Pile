using System;
using System.Collections;

namespace Pile
{
	public class Shader
	{
		public class Platform
		{
			public readonly List<ShaderAttribute> Attributes = new List<ShaderAttribute>() ~ DeleteContainerAndItems!(_);
			public readonly List<ShaderUniform> Uniforms = new List<ShaderUniform>() ~ DeleteContainerAndItems!(_);
		}

		readonly Platform platform;

		public int UniformCount => platform.Uniforms.Count;

		public this(ShaderSource source)
		{
			platform = Core.Graphics.[Friend]CreateShader(source);

		}

		public ~this()
		{
			delete platform;
		}

		public ShaderUniform GetUniform(int index) => platform.Uniforms[index];
	}
}
