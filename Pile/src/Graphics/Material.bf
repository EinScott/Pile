using System;
using System.Collections;

namespace Pile
{
	public class Material
	{
		public class Parameter
		{
			public readonly ShaderUniform Uniform;

			public Object Value { get; private set; }

			this(ShaderUniform uniform)
			{
				Uniform = uniform;

				switch (uniform.Type)
				{
				case .Int: Value = new int32[uniform.Size];
				case .Float: Value = new float[uniform.Size];
				case .Float2: Value = new float[uniform.Size * 2];
				case .Float3: Value = new float[uniform.Size * 3];
				case .Float4: Value = new float[uniform.Size * 4];
				case .Matrix3x2: Value = new float[uniform.Size * 6];
				case .Matrix4x4: Value = new float[uniform.Size * 16];
				case .Sampler: Value = new Texture[uniform.Size];
				case .Unknown: Value = null;
				}
			}

			public ~this()
			{
				delete Value;
			}

			public void SetTexture(Texture value, int index = 0)
			{
				AssertParameters(.Sampler, index);

				if (Value is Texture[])
					(Value as Texture[])[index] = value;
			}

			public Texture GetTexture(int index = 0)
			{
				AssertParameters(.Sampler, index);

				if (Value is Texture[])
					return (Value as Texture[])[index];
				return null;
			}

			public void SetInt(int32 value, int index = 0)
			{
				AssertParameters(.Int, index);

				if (Value is int32[])
					(Value as int32[])[index] = value;
			}

			public int32 GetInt(int index = 0)
			{
				AssertParameters(.Int, index);

				if (Value is int32[])
					return (Value as int32[])[index];
				return 0;
			}

			public void SetFloat(float value, int index = 0)
			{
				AssertParameters(.Float, index);

				if (Value is float[])
					(Value as float[])[index] = value;
			}

			public float GetFloat(int index = 0)
			{
				AssertParameters(.Float, index);

				if (Value is float[])
					return (Value as float[])[index];
				return 0;
			}

			public void SetFloat2((float, float) value, int index = 0)
			{
				let offset = index * 2;
				AssertParameters(.Float2, offset + 1);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					arr[offset] = value.0;
					arr[offset + 1] = value.1;
				}
			}

			public (float, float) GetFloat2(int index = 0)
			{
				let offset = index * 2;
				AssertParameters(.Float2, offset + 1);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					return (arr[offset], arr[offset + 1]);
				}
				return (0, 0);
			}

			public void SetFloat3((float, float, float) value, int index = 0)
			{
				let offset = index * 3;
				AssertParameters(.Float3, offset + 2);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					arr[offset] = value.0;
					arr[offset + 1] = value.1;
					arr[offset + 2] = value.2;
				}
			}

			public (float, float, float) GetFloat3(int index = 0)
			{
				let offset = index * 3;
				AssertParameters(.Float3, offset + 2);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					return (arr[offset], arr[offset + 1], arr[offset + 2]);
				}
				return (0, 0, 0);
			}

			public void SetFloat4((float, float, float, float) value, int index = 0)
			{
				let offset = index * 4;
				AssertParameters(.Float4, offset + 3);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					arr[offset] = value.0;
					arr[offset + 1] = value.1;
					arr[offset + 2] = value.2;
					arr[offset + 3] = value.3;
				}
			}

			public (float, float, float, float) GetFloat4(int index = 0)
			{
				let offset = index * 4;
				AssertParameters(.Float4, offset + 3);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					return (arr[offset], arr[offset + 1], arr[offset + 2], arr[offset + 3]);
				}
				return (0, 0, 0, 0);
			}

			public void SetMat3x2((float, float, float, float, float, float) value, int index = 0)
			{
				let offset = index * 6;
				AssertParameters(.Matrix3x2, offset + 5);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					arr[offset] = value.0;
					arr[offset + 1] = value.1;
					arr[offset + 2] = value.2;
					arr[offset + 3] = value.3;
					arr[offset + 4] = value.4;
					arr[offset + 5] = value.5;
				}
			}

			public (float, float, float, float, float, float) GetMat3x2(int index = 0)
			{
				let offset = index * 6;
				AssertParameters(.Matrix3x2, offset + 5);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					return (arr[offset], arr[offset + 1], arr[offset + 2], arr[offset + 3], arr[offset + 4], arr[offset + 5]);
				}
				return (0, 0, 0, 0, 0, 0);
			}

			// You should probably replace this once you have a mat type??, this looks very shitty
			public void SetMat4x4((	float, float, float, float,
									float, float, float, float,
									float, float, float, float,
									float, float, float, float) value, int index = 0)
			{
				let offset = index * 16;
				AssertParameters(.Matrix3x2, offset + 15);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					arr[offset] = value.0;
					arr[offset + 1] = value.1;
					arr[offset + 2] = value.2;
					arr[offset + 3] = value.3;
					arr[offset + 4] = value.4;
					arr[offset + 5] = value.5;
					arr[offset + 6] = value.6;
					arr[offset + 7] = value.7;
					arr[offset + 8] = value.8;
					arr[offset + 9] = value.9;
					arr[offset + 10] = value.10;
					arr[offset + 11] = value.11;
					arr[offset + 12] = value.12;
					arr[offset + 13] = value.13;
					arr[offset + 14] = value.14;
					arr[offset + 15] = value.15;
				}
			}

			public (float, float, float, float,
					float, float, float, float,
					float, float, float, float,
					float, float, float, float) GetMat4x4(int index = 0)
			{
				let offset = index * 16;
				AssertParameters(.Matrix3x2, offset + 15);

				if (Value is float[])
				{
					let arr = (Value as float[]);
					return (arr[offset], arr[offset + 1], arr[offset + 2], arr[offset + 3],
							arr[offset + 4], arr[offset + 5], arr[offset + 6], arr[offset + 7],
							arr[offset + 8], arr[offset + 9], arr[offset + 10], arr[offset + 11],
							arr[offset + 12], arr[offset + 13], arr[offset + 14], arr[offset + 15]);
				}
				return (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			}

			void AssertParameters(UniformType expected, int index)
			{
				// Assure valid access
				Runtime.Assert(Uniform.Type == expected, scope String("Material Parameter {0} was expected to be of UniformType {1} instead of {2}")..Format(Uniform.Name, expected, Uniform.Type));
				Runtime.Assert(index > 0 && index < Uniform.Size, scope String("The Size of Material Parameter {0} is {1}, but was trying to access index {2}")..Format(Uniform.Name, Uniform.Size, index));
			}
		}

		public readonly Shader Shader;

		public int ParameterCount => parameters.Count;
		readonly Parameter[] parameters;

		public this(Shader shader)
		{
			Shader = shader;

			parameters = new Parameter[shader.UniformCount];
			for (int i = 0; i < shader.UniformCount; i++)
				parameters[i] = new [Friend]Parameter(shader.GetUniform(i));
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
