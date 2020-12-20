using System;
using System.Collections;

using internal Pile;

namespace Pile
{
	public class Material
	{
		public class Parameter
		{
			public readonly ShaderUniform Uniform;

			public Object Value { get; private set; }

			internal this(ShaderUniform uniform)
			{
				Uniform = uniform;

				switch (uniform.Type)
				{
				case .Int: Value = new int32[uniform.Length];
				case .Float: Value = new float[uniform.Length];
				case .Float2: Value = new float[uniform.Length * 2];
				case .Float3: Value = new float[uniform.Length * 3];
				case .Float4: Value = new float[uniform.Length * 4];
				case .Matrix3x2: Value = new float[uniform.Length * 6];
				case .Matrix4x4: Value = new float[uniform.Length * 16];
				case .Sampler: Value = new Texture[uniform.Length];
				case .Unknown: Value = null;
				}
			}

			public ~this()
			{
				delete Value;
			}

			public Result<void> SetTexture(Texture value, int index = 0)
			{
				Try!(AssertParameters(.Sampler, index));

				if (let val = Value as Texture[])
					val[index] = value;

				return .Ok;
			}

			public Result<Texture> GetTexture(int index = 0)
			{
				Try!(AssertParameters(.Sampler, index));

				if (let val = Value as Texture[])
					return val[index];
				return .Err;
			}

			public Result<void> SetInt(int32 value, int index = 0)
			{
				Try!(AssertParameters(.Int, index));

				if (let val = Value as int32[])
					val[index] = value;

				return .Ok;
			}

			public Result<int32> GetInt(int index = 0)
			{
				Try!(AssertParameters(.Int, index));

				if (let val = Value as int32[])
					return val[index];

				return .Err;
			}

			public Result<void> SetFloat(float value, int index = 0)
			{
				Try!(AssertParameters(.Float, index));

				if (let val = Value as float[])
					val[index] = value;

				return .Ok;
			}

			public Result<float> GetFloat(int index = 0)
			{
				Try!(AssertParameters(.Float, index));

				if (let val = Value as float[])
					return val[index];

				return .Err;
			}

			public Result<void> SetFloat2((float, float) value, int index = 0)
			{
				let offset = index * 2;
				Try!(AssertParameters(.Float2, index));

				if (let val = Value as float[])
				{
					val[offset] = value.0;
					val[offset + 1] = value.1;
				}

				return .Ok;
			}

			public Result<void> SetFloat2(Vector2 value, int index = 0)
			{
				let offset = index * 2;
				Try!(AssertParameters(.Float2, index));

				if (let val = Value as float[])
				{
					val[offset] = value.X;
					val[offset + 1] = value.Y;
				}

				return .Ok;
			}

			public Result<Vector2> GetFloat2(int index = 0)
			{
				let offset = index * 2;
				Try!(AssertParameters(.Float2, index));

				if (let val = Value as float[])
				{
					return Vector2(val[offset], val[offset + 1]);
				}

				return .Err;
			}

			public Result<void> SetFloat3((float, float, float) value, int index = 0)
			{
				let offset = index * 3;
				Try!(AssertParameters(.Float3, index));

				if (let val = Value as float[])
				{
					val[offset] = value.0;
					val[offset + 1] = value.1;
					val[offset + 2] = value.2;
				}

				return .Ok;
			}

			public Result<void> SetFloat3(Vector3 value, int index = 0)
			{
				let offset = index * 3;
				Try!(AssertParameters(.Float3, index));

				if (let val = Value as float[])
				{
					val[offset] = value.X;
					val[offset + 1] = value.Y;
					val[offset + 2] = value.Z;
				}

				return .Ok;
			}

			public Result<Vector3> GetFloat3(int index = 0)
			{
				let offset = index * 3;
				Try!(AssertParameters(.Float3, index));

				if (let val = Value as float[])
				{
					return Vector3(val[offset], val[offset + 1], val[offset + 2]);
				}

				return .Err;
			}

			public Result<void> SetFloat4((float, float, float, float) value, int index = 0)
			{
				let offset = index * 4;
				Try!(AssertParameters(.Float4, index));

				if (let val = Value as float[])
				{
					val[offset] = value.0;
					val[offset + 1] = value.1;
					val[offset + 2] = value.2;
					val[offset + 3] = value.3;
				}

				return .Ok;
			}

			public Result<(float, float, float, float)> GetFloat4(int index = 0)
			{
				let offset = index * 4;
				Try!(AssertParameters(.Float4, index));

				if (let val = Value as float[])
				{
					return (val[offset], val[offset + 1], val[offset + 2], val[offset + 3]);
				}

				return .Err;
			}

			public Result<void> SetMat3x2(Matrix3x2 value, int index = 0)
			{
				let offset = index * 6;
				Try!(AssertParameters(.Matrix3x2, index));

				if (let val = Value as float[])
				{
					val[offset] = value.M11;
					val[offset + 1] = value.M12;
					val[offset + 2] = value.M21;
					val[offset + 3] = value.M22;
					val[offset + 4] = value.M31;
					val[offset + 5] = value.M32;
				}

				return .Ok;
			}

			public Result<Matrix3x2> GetMat3x2(int index = 0)
			{
				let offset = index * 6;
				Try!(AssertParameters(.Matrix3x2, index));

				if (let val = Value as float[])
				{
					return Matrix3x2(val[offset], val[offset + 1], val[offset + 2], val[offset + 3], val[offset + 4], val[offset + 5]);
				}

				return .Err;
			}

			public Result<void> SetMatrix4x4(Matrix4x4 value, int index = 0)
			{
				let offset = index * 16;
				Try!(AssertParameters(.Matrix4x4, index));

				if (let val = Value as float[])
				{
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
				}

				return .Ok;
			}

			public Result<Matrix4x4> GetMatrix4x4(int index = 0)
			{
				let offset = index * 16;
				Try!(AssertParameters(.Matrix4x4, index));

				if (let val = Value as float[])
				{
					return Matrix4x4(val[offset], val[offset + 1], val[offset + 2], val[offset + 3],
									val[offset + 4], val[offset + 5], val[offset + 6], val[offset + 7],
									val[offset + 8], val[offset + 9], val[offset + 10], val[offset + 11],
									val[offset + 12], val[offset + 13], val[offset + 14], val[offset + 15]);
				}

				return .Err;
			}

			Result<void> AssertParameters(UniformType expected, int index)
			{
				// Assure valid access
				if (Uniform.Type != expected) LogErrorReturn!(scope $"Material Parameter {Uniform.Name} was expected to be of UniformType {expected} instead of {Uniform.Type}");
				if (index < 0 && index >= Uniform.Length) LogErrorReturn!(scope $"The Size of Material Parameter {Uniform.Name} is {Uniform.Length}, but was trying to access index {index}");

				return .Ok;
			}
		}

		public readonly Shader Shader;

		public int ParameterCount => parameters.Count;
		readonly Parameter[] parameters ~ DeleteContainerAndItems!(_);

		public this(Shader shader)
		{
			Shader = shader;

			parameters = new Parameter[shader.Uniforms.Length];
			for (int i = 0; i < shader.Uniforms.Length; i++)
				parameters[i] = new Parameter(shader.Uniforms[i]);
		}

		public Parameter this[StringView name]
		{
			get
			{
				for (let param in parameters)
					if (param.Uniform.Name == name)
						return param;
				return null;
			}
		}

		public Parameter this[int index]
		{
			get => parameters[index];
		}
	}
}
