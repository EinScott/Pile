using System;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	class Shader : IPersistentAsset<ShaderData>
	{
		readonly List<ShaderAttrib> attributes = new List<ShaderAttrib>() ~ DeleteContainerAndItems!(_);
		readonly List<ShaderUniform> uniforms = new List<ShaderUniform>() ~ DeleteContainerAndItems!(_);
		
		internal List<Material> materialDependants = new .() ~
		{
			for (let mat in _)
				mat.shader = null; // Don't make them access deleted stuff!

			delete _;
		};

		public readonly ReadOnlyList<ShaderAttrib> Attributes;
		public readonly ReadOnlyList<ShaderUniform> Uniforms;

		public this(ShaderData data)
		{
			Debug.Assert(Core.run, "Core needs to be initialized before creating platform dependent objects");
			Debug.Assert(data != null, "ShaderData cannot be null");

			Initialize();

			Set(data);
			ReflectShader();

			Attributes = ReadOnlyList<ShaderAttrib>(attributes);
			Uniforms = ReadOnlyList<ShaderUniform>(uniforms);
		}

		public Result<void> Reset(ShaderData data)
		{
			Debug.Assert(data != null, "ShaderData cannot be null");

			Try!(Set(data));
			ReflectShader();

			for (let m in materialDependants)
				m.OnShaderReset();

			return .Ok;
		}

		void ReflectShader()
		{
			ReflectCounts(let attribCount, let uniformCount);
			
			let name = scope String();
			{
				let current = scope List<ShaderAttrib>(attributes.GetEnumerator());
				attributes.Clear();

				for (let i < attribCount)
				{
					name.Clear();

					if(ReflectAttrib(i, name, let location, let length) case .Err)
						continue;

					// If this attrib already exists unchanged
					let found = current.FindIndex(scope (x) => x.Name == name && x.Location == location);
					if (found != -1)
					{
						attributes.Add(current[found]);
						current.RemoveAtFast(found);
					}
					else attributes.Add(new ShaderAttrib(name, location));
				}

				// Delete old ones
				for (let a in current)
					delete a;
			}

			{
				let current = scope List<ShaderUniform>(uniforms.GetEnumerator());
				uniforms.Clear();

				for (let i < uniformCount)
				{
					name.Clear();

					if (ReflectUniform(i, name, let location, let length, let type) case .Err)
						continue;

					// If this uniform already exists unchanged
					let found = current.FindIndex(scope (x) => x.Name == name && x.Location == location && x.Length == length && x.Type == type);
					if (found != -1)
					{
						uniforms.Add(current[found]);
						current.RemoveAtFast(found);
					}
					else uniforms.Add(new ShaderUniform(name, location, length, type));
				}

				// Delete old ones
				for (let u in current)
					delete u;
			}
		}

		protected extern void Initialize();

		/// On .Err, the Shader should still function like before ideally
		protected extern Result<void> Set(ShaderData data);

		protected extern void ReflectCounts(out uint32 attributeCount, out uint32 uniformCount);
		protected extern Result<void> ReflectAttrib(uint32 index, String nameBuffer, out uint32 location, out uint32 length);
		protected extern Result<void> ReflectUniform(uint32 index, String nameBuffer, out uint32 location, out uint32 length, out UniformType type);
	}
}
