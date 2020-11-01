using System;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class Shader
	{
		// Maintained by platform
		public readonly ReadOnlySpan<ShaderAttribute> Attributes;
		public readonly ReadOnlySpan<ShaderUniform> Uniforms;

		internal class Platform
		{
			internal readonly List<ShaderAttribute> Attributes = new List<ShaderAttribute>() ~ DeleteContainerAndItems!(_);
			internal readonly List<ShaderUniform> Uniforms = new List<ShaderUniform>() ~ DeleteContainerAndItems!(_);
		}

		internal readonly Platform platform ~ delete _;

		public this(ShaderData source)
		{
			Debug.Assert(Core.Graphics != null, "Core needs to be initialized before creating platform dependant objects");

			platform = Core.Graphics.CreateShader(source);

			Attributes = platform.Attributes;
			Uniforms = platform.Uniforms;
		}
	}
}
