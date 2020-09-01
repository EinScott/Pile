using OpenGL43;
using System;

namespace Pile.Implementations
{
	public class GL_Shader : Shader.Platform
	{
		uint32 programID;

		readonly GL_Graphics graphics;

		private this(GL_Graphics graphics, ShaderSource source)
		{
			this.graphics = graphics;

			programID = (uint32)GL.glCreateProgram();

			// Prepare shaders
			let shaders = scope uint[2];
			shaders[0] = PrepareShader(source.vertexSource, GL.GL_VERTEX_SHADER);
			shaders[1] = PrepareShader(source.fragmentSource, GL.GL_FRAGMENT_SHADER);

			GL.glLinkProgram(programID);

			// Error
			{
				int32 len = 0;
				GL.glGetProgramiv(programID, GL.GL_INFO_LOG_LENGTH, &len);

				if (len > 0)
				{
					var s = new char8[len];

					GL.glGetProgramInfoLog(programID, len, &len, &s[0]);
					Runtime.FatalError(scope String("Error linking program: {0}")..Format(scope String(&s[0], len)));
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
				int32 trash1 = 0;

				// Get attributes
				int32 count = 0;
				var buf = scope String(256);
				GL.glGetProgramiv(programID, GL.GL_ACTIVE_ATTRIBUTES, &count);
				for	(int i = 0; i < count; i++)
				{
					uint32 trash2 = 0;
					GL.glGetActiveAttrib(programID, (uint)i, 256, &trash1, &trash1, &trash2, buf);
	
					int location = GL.glGetAttribLocation(programID, buf.CStr());
					if (location >= 0)
						Attributes.Add(new ShaderAttribute(buf, (uint)location));
	
					buf.Clear();
				}
	
				// Get uniforms
				GL.glGetProgramiv(programID, GL.GL_ACTIVE_UNIFORMS, &count);
				for (int i = 0; i < count; i++)
				{
					int32 length = 0; // Not length of the string, but the uniform
					uint32 type = 0;
					GL.glGetActiveUniform(programID, (uint)i, 256, &trash1, &length, &type, buf);
	
					int location = GL.glGetUniformLocation(programID, buf.CStr());
					if (location >= 0)
					{
						if (length > 1 && buf.EndsWith("[0]"))
							buf.RemoveFromEnd(3);
						Uniforms.Add(new ShaderUniform(buf, location, length, GlTypeToEnum(type)));
					}	
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

			uint PrepareShader(String source, uint64 glShaderType)
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

 						Runtime.FatalError(scope String("Error compiling {0} shader: {1}")..Format(glShaderType == GL.GL_VERTEX_SHADER ? "vertex" : "fragment", scope String(&s[0], len)));
					}
				}

				GL.glAttachShader(programID, id);

				return id;
			}
		}

		public void Use()
		{
			GL.glUseProgram(programID);

			// This goes through all parameters of a material (holds shader uniforms and values for them)
			// and binds the stuff for each uniform at the uniform location
		}

		public ~this()
		{
			if (programID != 0)
			{
				graphics.[Friend]programsToDelete.Add(programID);
			}
		}
	}
}
