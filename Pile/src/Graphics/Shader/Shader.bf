using System;
using System.Collections;

namespace Pile
{
	public class Shader
	{
		// Access lists directly
		readonly List<ShaderAttribute> Attributes;
		readonly List<ShaderUniform> Uniforms;

		public class Platform
		{
			public readonly List<ShaderAttribute> Attributes = new List<ShaderAttribute>() ~ DeleteContainerAndItems!(_);
			public readonly List<ShaderUniform> Uniforms = new List<ShaderUniform>() ~ DeleteContainerAndItems!(_);
		}

		readonly Platform platform ~ delete _;

		public int UniformCount => Uniforms.Count;

		public this(ShaderData source)
		{
			platform = Core.Graphics.[Friend]CreateShader(source);

			Attributes = platform.Attributes;
			Uniforms = platform.Uniforms;
		}
	}
}
