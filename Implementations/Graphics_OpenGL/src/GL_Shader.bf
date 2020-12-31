using OpenGL43;
using System;

using internal Pile;

namespace Pile
{
	extension Shader
	{
		uint32 programID;

		protected internal override void Initialize(ShaderData source)
		{
			Compile(source);
		}

		protected internal override void Compile(ShaderData source)
		{
			Runtime.Assert( source.vertexSource.Length > 0 &&  source.fragmentSource.Length > 0, "At least vertex and fragment shader must be given to initialize gl shader");

			programID = (uint32)GL.glCreateProgram();

			// Prepare shaders
			let shaders = scope uint[2];
			shaders[0] = PrepareShader(source.vertexSource, GL.GL_VERTEX_SHADER);
			shaders[1] = PrepareShader(source.fragmentSource, GL.GL_FRAGMENT_SHADER);
			shaders[1] = source.geometrySource == String.Empty ? 0 : PrepareShader(source.geometrySource, GL.GL_GEOMETRY_SHADER);

			GL.glLinkProgram(programID);

			// Error
			{
				int32 linked = GL.GL_FALSE;
				GL.glGetProgramiv(programID, GL.GL_LINK_STATUS, &linked);

				if (linked == GL.GL_FALSE)
				{
					int32 len = 0;
					GL.glGetProgramiv(programID, GL.GL_INFO_LOG_LENGTH, &len);

					if (len > 0)
					{
						var s = new char8[len];

						GL.glGetProgramInfoLog(programID, len, &len, &s[0]);
						Core.FatalError(scope $"Error linking shader program: {StringView(&s[0], len)}");
					}
				}
			}

			// Delete shaders
			for (int i = 0; i < shaders.Count; i++)
			{
				if (shaders[i] != 0)
				{
					GL.glDetachShader(programID, shaders[i]);
					GL.glDeleteShader(shaders[i]);
				}
			}

			// Get program parameters
			{
				// Get attributes
				int32 count = 0;
				var cBuf = scope char8[256];
				let string = scope String();
				int32 actualLength = 0;
				GL.glGetProgramiv(programID, GL.GL_ACTIVE_ATTRIBUTES, &count);
				for	(int i = 0; i < count; i++)
				{
					uint32 trash2 = 0; // We dont care about these
					int32 trash1 = 0;
					GL.glGetActiveAttrib(programID, (uint)i, 256, &actualLength, &trash1, &trash2, &cBuf[0]);
					string.Append(&cBuf[0], actualLength);

					int location = GL.glGetAttribLocation(programID, string.CStr());
					if (location >= 0)
						attributes.Add(new ShaderAttribute(string, (uint)location));

					string.Clear();

					// Clear buf
					for (int j = 0; j < cBuf.Count; j++)
						cBuf[j] = 0;
				}

				// Get uniforms
				GL.glGetProgramiv(programID, GL.GL_ACTIVE_UNIFORMS, &count);
				for (int i = 0; i < count; i++)
				{
					int32 length = 0;
					uint32 type = 0;
					GL.glGetActiveUniform(programID, (uint)i, 256, &actualLength, &length, &type, &cBuf[0]);
					string.Append(&cBuf[0], actualLength);

					int location = GL.glGetUniformLocation(programID, string.CStr());
					if (location >= 0)
					{
						if (length > 1 && string.EndsWith("[0]"))
							string.RemoveFromEnd(3);
						uniforms.Add(new ShaderUniform(string, location, length, GlTypeToEnum(type)));
					}

					string.Clear();

					// Clear buf
					for (int j = 0; j < cBuf.Count; j++)
						cBuf[j] = 0;
				}
			}

			UniformType GlTypeToEnum(uint type)
			{
				switch (type)
				{
				case GL.GL_INT: return .Int;
				case GL.GL_FLOAT: return .Float;
				case GL.GL_FLOAT_VEC2: return .Float2;
				case GL.GL_FLOAT_VEC3: return .Float3;
				case GL.GL_FLOAT_VEC4: return .Float4;
				case GL.GL_FLOAT_MAT3x2: return .Matrix3x2;
				case GL.GL_FLOAT_MAT4: return .Matrix4x4;
				case GL.GL_SAMPLER_2D: return .Sampler;
				default: return .Unknown;
				}
			}

			uint PrepareShader(String source, uint glShaderType)
			{
				uint id = GL.glCreateShader(glShaderType);

				var cs = source.CStr();
				int32 l = (int32)source.Length;
				
				GL.glShaderSource(id, 1, &cs, &l);
				GL.glCompileShader(id);

				// Error
				{
					int32 compiled = GL.GL_FALSE;
					GL.glGetShaderiv(id, GL.GL_COMPILE_STATUS, &compiled);
					
					if (compiled == GL.GL_FALSE)
					{
						int32 len = 0;
						GL.glGetShaderiv(id, GL.GL_INFO_LOG_LENGTH, &len);
						var s = new char8[len];

						GL.glGetShaderInfoLog(id, len, &len, &s[0]);

						Core.FatalError(scope String()..AppendF("Error compiling {} shader: {}", GetShaderTypeName(glShaderType), StringView(&s[0], len)));
					}
				}

				GL.glAttachShader(programID, id);

				return id;
			}

			StringView GetShaderTypeName(uint glShaderType)
			{
				switch (glShaderType)
				{
				case GL.GL_VERTEX_SHADER: return "vertex";
				case GL.GL_FRAGMENT_SHADER: return "fragment";
				case GL.GL_GEOMETRY_SHADER: return "geometry";
				default: return "<unknown type>";
				}
			}
		}

		public ~this()
		{
			if (programID != 0)
			{
				Core.Graphics.programsToDelete.Add(programID);
			}
		}

		internal void Use(Material material)
		{
			GL.glUseProgram(programID);

			// This goes through all parameters of a material (holds shader uniforms and values for them)
			// and binds the stuff for each uniform at the uniform location

			int32 textureSlot = 0;

			for (int i = 0; i < material.ParameterCount; i++)
			{
				let parameter = material[i];
				let uniform = parameter.Uniform;

				switch (uniform.Type)
				{
				case .Sampler:
					{
						int32[] n = scope int32[uniform.Length];

						let textures = (parameter.Value as Texture[]);
						for (int j = 0; j < uniform.Length; j++)
						{
						    let id = textures[j]?.textureID ?? 0;

						    GL.glActiveTexture(GL.GL_TEXTURE0 + (uint)textureSlot);
						    GL.glBindTexture(GL.GL_TEXTURE_2D, id);

						    n[j] = textureSlot;
						    textureSlot++;
						}

						GL.glUniform1iv(uniform.Location, uniform.Length, &n[0]);
					}
				case .Int:
					GL.glUniform1iv(uniform.Location, uniform.Length, &(parameter.Value as int32[])[0]);
				case .Float:
					GL.glUniform1fv(uniform.Location, uniform.Length, &(parameter.Value as float[])[0]);
				case .Float2:
					GL.glUniform2fv(uniform.Location, uniform.Length, &(parameter.Value as float[])[0]);
				case .Float3:
					GL.glUniform3fv(uniform.Location, uniform.Length, &(parameter.Value as float[])[0]);
				case .Float4:
					GL.glUniform4fv(uniform.Location, uniform.Length, &(parameter.Value as float[])[0]);
				case .Matrix3x2:
					GL.glUniformMatrix3x2fv(uniform.Location, uniform.Length, GL.GL_FALSE, &(parameter.Value as float[])[0]);
				case .Matrix4x4:
					GL.glUniformMatrix4fv(uniform.Location, uniform.Length, GL.GL_FALSE, &(parameter.Value as float[])[0]);
				case .Unknown:
				}
			}
		}
	}
}
