using System;
using System.Diagnostics;
using System.Collections;

using internal Pile;

namespace Pile
{
	class Material
	{
		public struct Parameter
		{
			public readonly ShaderUniform Uniform;
			internal readonly uint8[] memory;

			internal this(ShaderUniform uniform)
			{
				Uniform = uniform;
				memory = new uint8[uniform.Type.GetSize(uniform.Length)];
			}

			internal void Dispose()
			{
				delete memory;
			}

			[Inline]
			public void SetTexture(Texture value, int index = 0)
			{
				AssertParameters(.Sampler, index);

				let val = (Texture*)&memory[[Unchecked]0];
				val[index] = value;
			}

			[Inline]
			public Texture GetTexture(int index = 0)
			{
				AssertParameters(.Sampler, index);

				let val = (Texture*)&memory[[Unchecked]0];

				return val[index];
			}

			[Inline]
			public void SetInt(int32 value, int index = 0)
			{
				AssertParameters(.Int, index);

				let val = (int32*)&memory[[Unchecked]0];
				val[index] = value;
			}

			[Inline]
			public int32 GetInt(int index = 0)
			{
				AssertParameters(.Int, index);

				let val = (int32*)&memory[[Unchecked]0];

				return val[index];
			}

			[Inline]
			public void SetFloat(float value, int index = 0)
			{
				AssertParameters(.Float, index);

				let val = (float*)&memory[[Unchecked]0];
				val[index] = value;
			}

			[Inline]
			public float GetFloat(int index = 0)
			{
				AssertParameters(.Float, index);

				let val = (float*)&memory[[Unchecked]0];

				return val[index];
			}

			public void SetFloat2(Vector2 value, int index = 0)
			{
				AssertParameters(.Float2, index);
				
				let offset = index * 2;
				let val = (float*)&memory[[Unchecked]0];
				val[offset] = value.X;
				val[offset + 1] = value.Y;
			}

			public Vector2 GetFloat2(int index = 0)
			{
				AssertParameters(.Float2, index);
				
				let offset = index * 2;
				let val = (float*)&memory[[Unchecked]0];

				return Vector2(val[offset], val[offset + 1]);
			}

			public void SetFloat3(Vector3 value, int index = 0)
			{
				AssertParameters(.Float3, index);
				
				let offset = index * 3;
				let val = (float*)&memory[[Unchecked]0];
				val[offset] = value.X;
				val[offset + 1] = value.Y;
				val[offset + 2] = value.Z;
			}

			public Vector3 GetFloat3(int index = 0)
			{
				AssertParameters(.Float3, index);
				
				let offset = index * 3;
				let val = (float*)&memory[[Unchecked]0];

				return Vector3(val[offset], val[offset + 1], val[offset + 2]);
			}

			public void SetFloat4(Vector4 value, int index = 0)
			{
				AssertParameters(.Float4, index);
				
				let offset = index * 4;
				let val = (float*)&memory[[Unchecked]0];
				val[offset] = value.X;
				val[offset + 1] = value.Y;
				val[offset + 2] = value.Z;
				val[offset + 3] = value.W;
			}

			public Result<Vector4> GetFloat4(int index = 0)
			{
				AssertParameters(.Float4, index);
				
				let offset = index * 4;
				let val = (float*)&memory[[Unchecked]0];

				return Vector4(val[offset], val[offset + 1], val[offset + 2], val[offset + 3]);
			}

			public Result<void> SetMatrix3x2(Matrix3x2 value, int index = 0)
			{
				AssertParameters(.Matrix3x2, index);
				
				let offset = index * 6;
				let val = (float*)&memory[[Unchecked]0];
				val[offset] = value.M11;
				val[offset + 1] = value.M12;
				val[offset + 2] = value.M21;
				val[offset + 3] = value.M22;
				val[offset + 4] = value.M31;
				val[offset + 5] = value.M32;

				return .Ok;
			}

			public Result<Matrix3x2> GetMatrix3x2(int index = 0)
			{
				AssertParameters(.Matrix3x2, index);
				
				let offset = index * 6;
				let val = (float*)&memory[[Unchecked]0];

				return Matrix3x2(val[offset], val[offset + 1], val[offset + 2], val[offset + 3], val[offset + 4], val[offset + 5]);
			}

			public Result<void> SetMatrix4x4(Matrix4x4 value, int index = 0)
			{
				AssertParameters(.Matrix4x4, index);
				
				let offset = index * 16;
				let val = (float*)&memory[[Unchecked]0];
				val[offset] = value.M11;
				val[offset + 1] = value.M12;
				val[offset + 2] = value.M13;
				val[offset + 3] = value.M14;
				val[offset + 4] = value.M21;
				val[offset + 5] = value.M22;
				val[offset + 6] = value.M23;
				val[offset + 7] = value.M24;
				val[offset + 8] = value.M31;
				val[offset + 9] = value.M32;
				val[offset + 10] = value.M33;
				val[offset + 11] = value.M34;
				val[offset + 12] = value.M41;
				val[offset + 13] = value.M42;
				val[offset + 14] = value.M43;
				val[offset + 15] = value.M44;

				return .Ok;
			}

			public Result<Matrix4x4> GetMatrix4x4(int index = 0)
			{
				AssertParameters(.Matrix4x4, index);
				
				let offset = index * 16;
				let val = (float*)&memory[[Unchecked]0];

				return Matrix4x4(val[offset], val[offset + 1], val[offset + 2], val[offset + 3],
					val[offset + 4], val[offset + 5], val[offset + 6], val[offset + 7],
					val[offset + 8], val[offset + 9], val[offset + 10], val[offset + 11],
					val[offset + 12], val[offset + 13], val[offset + 14], val[offset + 15]);
			}

#if !DEBUG
			[SkipCall]
#endif
			[Inline]
			void AssertParameters(UniformType expected, int index)
			{
				// Assure valid access
				if (Uniform.Type != expected)
					Runtime.FatalError(scope $"Material Parameter {Uniform.Name} was expected to be of UniformType {expected} instead of {Uniform.Type}");
				if (index < 0 || (uint)index >= Uniform.Length)
					Runtime.FatalError(scope $"The Size of Material Parameter {Uniform.Name} is {Uniform.Length}, but was trying to access index {index}");
			}
		}

		[Inline]
		public Shader Shader => shader;
		[Inline]
		public int ParameterCount => parameters.Count;

		// If this is null at some point, that means that the shader was already deleted. It will null itself on dependant materials
		internal Shader shader;
		Parameter[] parameters;

		typealias ParamLookupPair = (Parameter* param, uint32 index);
		Dictionary<StringView, ParamLookupPair> paramsByName = new Dictionary<StringView, ParamLookupPair>() ~ delete _;

		public this(Shader shader)
		{
			this.shader = shader;
			shader.materialDependants.Add(this);

			parameters = new Parameter[Shader.Uniforms.Count];
			for (int i = 0; i < Shader.Uniforms.Count; i++)
				parameters[i] = Parameter(Shader.Uniforms[i]);

			UpdateParamsByName();
		}

		public ~this()
		{
			if (shader != null)
				shader.materialDependants.Remove(this);

			for (let param in ref parameters)
				param.Dispose();
			delete parameters;
		}

		internal void OnShaderReset()
		{
			// Check if the uniforms have changed & patch
			let newParams = scope List<Parameter>();
			let current = scope List<Parameter>(parameters.GetEnumerator());

			for (let s in Shader.Uniforms)
			{
				int alreadyExists = -1;
				for (let i < current.Count)
					if (current[i].Uniform === s && current[i].Uniform.Name == s.Name)
						alreadyExists = i;

				if (alreadyExists != -1)
				{
					newParams.Add(current[alreadyExists]);
					current.RemoveAtFast(alreadyExists);
				}
				else newParams.Add(Parameter(s));
			}

			for (let p in current)
				p.Dispose();
			delete parameters;

			parameters = new Parameter[newParams.Count];
			newParams.CopyTo(parameters);

			UpdateParamsByName();
		}

		void UpdateParamsByName()
		{
			paramsByName.Clear();
			for (let i < parameters.Count)
				paramsByName.Add(parameters[[Unchecked]i].Uniform.Name, (&parameters[[Unchecked]i], (.)i));
		}

		public int IndexOf(StringView name)
		{
			if (paramsByName.TryGetValue(name, var entry))
				return entry.index;

			return -1;
		}

		public ref Parameter this[StringView name]
		{
			get
			{
				if (paramsByName.TryGetValue(name, var entry))
					return ref *entry.param;

				Runtime.FatalError("Couldn't find Parameter with given name on material (maybe optimized out?)");
			}
		}

		public ref Parameter this[int index]
		{
			[Inline]
			get => ref parameters[index];

			[Inline, Unchecked]
			get => ref parameters[[Unchecked]index];
		}
	}
}
