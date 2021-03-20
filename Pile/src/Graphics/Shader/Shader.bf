using System;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class Shader
	{
		readonly List<ShaderAttribute> attributes = new List<ShaderAttribute>() ~ DeleteContainerAndItems!(_);
		readonly List<ShaderUniform> uniforms = new List<ShaderUniform>() ~ DeleteContainerAndItems!(_);

		public readonly ReadOnlyList<ShaderAttribute> Attributes;
		public readonly ReadOnlyList<ShaderUniform> Uniforms;

		public this(ShaderData source)
		{
			Debug.Assert(Core.run, "Core needs to be initialized before creating platform dependent objects");

			Initialize(source);

			Attributes = ReadOnlyList<ShaderAttribute>(attributes);
			Uniforms = ReadOnlyList<ShaderUniform>(uniforms);
		}

		protected internal extern void Initialize(ShaderData source);
		protected internal extern void Compile(ShaderData source);
	}
}
