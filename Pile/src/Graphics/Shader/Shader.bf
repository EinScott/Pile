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

			Initialize();
			Set(source);

			Attributes = ReadOnlyList<ShaderAttribute>(attributes);
			Uniforms = ReadOnlyList<ShaderUniform>(uniforms);
		}

		protected extern void Initialize();

		// TODO: this should be public, but we also need to revisit code in Material to allow shaders to reset their source
		protected extern void Set(ShaderData source);
	}
}
