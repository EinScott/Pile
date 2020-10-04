using System;
using System.Collections;

namespace Pile
{
	public class Shader
	{
		// Maintained by platform
		public readonly ReadOnlySpan<ShaderAttribute> Attributes;
		public readonly ReadOnlySpan<ShaderUniform> Uniforms;

		public class Platform
		{
			public readonly List<ShaderAttribute> Attributes = new List<ShaderAttribute>() ~ DeleteContainerAndItems!(_);
			public readonly List<ShaderUniform> Uniforms = new List<ShaderUniform>() ~ DeleteContainerAndItems!(_);
		}

		readonly Platform platform ~ delete _;

		public this(ShaderData source)
		{
			platform = Core.Graphics.[Friend]CreateShader(source);

			Attributes = platform.Attributes;
			Uniforms = platform.Uniforms;
		}
	}
}
