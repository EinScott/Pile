using OpenGL45;
using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	extension Shader
	{
		uint32 programID;

		public ~this()
		{
			if (programID != 0)
			{
				Graphics.programsToDelete.Add(programID);
			}
		}

		protected override void Initialize() {}

		protected override Result<void> Set(ShaderData source)
		{
			Debug.Assert(source.vertexSource.Length > 0 &&  source.fragmentSource.Length > 0, "At least vertex and fragment shader must be given to initialize gl shader");

			let newProg = GL.glCreateProgram();

			// Prepare shaders
			let shaders = scope uint32[3];
			shaders[0] = PrepareShader!(source.vertexSource, GL.ShaderType.GL_VERTEX_SHADER);
			shaders[1] = PrepareShader!(source.fragmentSource, GL.ShaderType.GL_FRAGMENT_SHADER);
			shaders[2] = source.geometrySource == String.Empty ? 0 : PrepareShader!(source.geometrySource, GL.ShaderType.GL_GEOMETRY_SHADER);

			GL.glLinkProgram(newProg);

			// Error
			{
				int32 linked = 0; // GL_FALSE
				GL.glGetProgramiv(newProg, .GL_LINK_STATUS, &linked);

				if (linked == 0)
				{
					int32 len = 0;
					GL.glGetProgramiv(newProg, .GL_INFO_LOG_LENGTH, &len);

					if (len > 0)
					{
						var s = scope char8[len];

						GL.glGetProgramInfoLog(newProg, len, &len, s.Ptr);
						LogErrorReturn!(scope $"Error linking shader program: {StringView(s.Ptr, len)}");
					}
				}
			}

			// Delete shaders
			for (int i = 0; i < shaders.Count; i++)
			{
				if (shaders[i] != 0)
				{
					GL.glDetachShader(newProg, shaders[i]);
					GL.glDeleteShader(shaders[i]);
				}
			}

			// Apply
			if (programID != 0)
				Graphics.programsToDelete.Add(programID);
			programID = newProg;

			return .Ok;

			mixin PrepareShader(String source, GL.ShaderType glShaderType)
			{
				uint32 id = GL.glCreateShader(glShaderType);

				var cs = source.CStr();
				int32 l = (int32)source.Length;
				
				GL.glShaderSource(id, 1, &cs, &l);
				GL.glCompileShader(id);

				// Error
				{
					int32 compiled = 0; // GL_FALSE
					GL.glGetShaderiv(id, .GL_COMPILE_STATUS, &compiled);
					
					if (compiled == 0)
					{
						int32 len = 0;
						GL.glGetShaderiv(id, .GL_INFO_LOG_LENGTH, &len);
						var s = scope char8[len];

						GL.glGetShaderInfoLog(id, len, &len, s.Ptr);

						LogErrorReturn!(scope $"Error compiling {GetShaderTypeName(glShaderType)} shader: {StringView(s.Ptr, len)}");
					}
				}

				GL.glAttachShader(newProg, id);

				id
			}

			StringView GetShaderTypeName(GL.ShaderType glShaderType)
			{
				switch (glShaderType)
				{
				case .GL_VERTEX_SHADER: return "vertex";
				case .GL_FRAGMENT_SHADER: return "fragment";
				case .GL_GEOMETRY_SHADER: return "geometry";
				default: return "<unknown type>";
				}
			}
		}

		protected override void ReflectCounts(out uint32 attributeCount, out uint32 uniformCount)
		{
			Debug.Assert(programID != 0, "No shader program");

			attributeCount = Probe(.GL_ACTIVE_ATTRIBUTES);
			uniformCount = Probe(.GL_ACTIVE_UNIFORMS);

			uint32 Probe(GL.ProgramPropertyARB glParam)
			{
				int32 count = 0;
				GL.glGetProgramiv(programID, glParam, &count);
				return (.)count;
			}
		}

		protected override Result<void> ReflectAttrib(uint32 index, String nameBuffer, out uint32 location, out uint32 length)
		{
			// Get attribute
			var cBuf = scope char8[256];
			GL.AttributeType outType = ?;
			int32 outLen = ?;
			int32 outNameLen = ?;
			GL.glGetActiveAttrib(programID, index, 256, &outNameLen, &outLen, &outType, cBuf.Ptr);
			let outLoc = GL.glGetAttribLocation(programID, cBuf.Ptr);

			if (outLoc >= 0)
			{
				nameBuffer.Append(cBuf.Ptr, outNameLen);
				location = (.)outLoc;
				length = (.)outLen;
				return .Ok;
			}

			location = 0;
			length = 0;
			return .Err;
		}

		protected override Result<void> ReflectUniform(uint32 index, String nameBuffer, out uint32 location, out uint32 length, out UniformType type)
		{
			// Get uniform
			var cBuf = scope char8[256];
			GL.UniformType outType = ?;
			int32 outLen = ?;
			int32 outNameLen = ?;
			GL.glGetActiveUniform(programID, index, 256, &outNameLen, &outLen, &outType, cBuf.Ptr);
			let outLoc = GL.glGetUniformLocation(programID, cBuf.Ptr);

			if (outLoc >= 0)
			{
				nameBuffer.Append(cBuf.Ptr, outNameLen);
				if (outLen > 1 && nameBuffer.EndsWith("[0]"))
					nameBuffer.RemoveFromEnd(3);

				location = (.)outLoc;
				length = (.)outLen;
				type = GlTypeToEnum(outType);
				return .Ok;
			}

			location = 0;
			length = 0;
			type = .Unknown;
			return .Err;
		}

		[Inline]
		UniformType GlTypeToEnum(GL.UniformType type)
		{
			switch (type)
			{
			case .GL_INT: return .Int;
			case .GL_FLOAT: return .Float;
			case .GL_FLOAT_VEC2: return .Float2;
			case .GL_FLOAT_VEC3: return .Float3;
			case .GL_FLOAT_VEC4: return .Float4;
			case .GL_FLOAT_MAT3x2: return .Matrix3x2;
			case .GL_FLOAT_MAT4: return .Matrix4x4;
			case .GL_SAMPLER_2D: return .Sampler;
			default: return .Unknown;
			}
		}

		internal void Use(Material material)
		{
			if (!IsSetup)
			{
				Debug.FatalError("Using shader that was not initialized with ShaderData");
				return;
			}

			GL.glUseProgram(programID);

			// This goes through all parameters of a material (holds shader uniforms and values for them)
			// and binds the stuff for each uniform at the uniform location

			int32 textureSlot = 0;

			for (int i = 0; i < material.ParameterCount; i++)
			{
				let parameter = ref material[[Unchecked]i];
				let uniform = parameter.Uniform;

				switch (uniform.Type)
				{
				case .Sampler:
					{
						int32[] n = scope int32[uniform.Length];

						let textures = (Texture*)parameter.memory.Ptr;
						for (int j = 0; j < uniform.Length; j++)
						{
						    let id = textures[j]?.textureID ?? 0;

						    GL.glActiveTexture(.GL_TEXTURE0 + textureSlot);
						    GL.glBindTexture(.GL_TEXTURE_2D, id);

						    n[j] = textureSlot;
						    textureSlot++;
						}

						GL.glUniform1iv((.)uniform.Location, (.)uniform.Length, n.Ptr);
					}
				case .Int:
					GL.glUniform1iv((.)uniform.Location, (.)uniform.Length, (int32*)parameter.memory.Ptr);
				case .Float:
					GL.glUniform1fv((.)uniform.Location, (.)uniform.Length, (float*)parameter.memory.Ptr);
				case .Float2:
					GL.glUniform2fv((.)uniform.Location, (.)uniform.Length, (float*)parameter.memory.Ptr);
				case .Float3:
					GL.glUniform3fv((.)uniform.Location, (.)uniform.Length, (float*)parameter.memory.Ptr);
				case .Float4:
					GL.glUniform4fv((.)uniform.Location, (.)uniform.Length, (float*)parameter.memory.Ptr);
				case .Matrix3x2:
					GL.glUniformMatrix3x2fv((.)uniform.Location, (.)uniform.Length, .GL_FALSE, (float*)parameter.memory.Ptr);
				case .Matrix4x4:
					GL.glUniformMatrix4fv((.)uniform.Location, (.)uniform.Length, .GL_FALSE, (float*)parameter.memory.Ptr);
				case .Unknown:
				}
			}
		}
	}
}
