using System;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public class Shader
	{
		readonly List<ShaderAttribute> attributes = new List<ShaderAttribute>() ~ DeleteContainerAndItems!(_);
		readonly List<ShaderUniform> uniforms = new List<ShaderUniform>() ~ DeleteContainerAndItems!(_);

		public readonly ReadOnlySpan<ShaderAttribute> Attributes;
		public readonly ReadOnlySpan<ShaderUniform> Uniforms;

		public this(ShaderData source)
		{
			Debug.Assert(Core.Graphics != null, "Core needs to be initialized before creating platform dependent objects");

			Initialize(source);

			Attributes = attributes;
			Uniforms = uniforms;
		}

		protected internal extern void Initialize(ShaderData source);
		protected internal extern void Compile(ShaderData source);
	}
}
