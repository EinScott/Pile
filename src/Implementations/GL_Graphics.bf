using OpenGL46;
using System;

namespace Pile.Implementations
{
	public class GL_Graphics : Graphics, IGraphicsOpenGL
	{
		public IGraphicsOpenGL.GLProfile Profile => IGraphicsOpenGL.GLProfile.Core;
		public override int32 MajorVersion => 4;
		public override int32 MinorVersion => 6;

		int32 maxTextureSize = 0;
		public override int32 MaxTextureSize
		{
			get => maxTextureSize;
		}

		static ISystemOpenGL system;
		static void* GetProcAddress(StringView procName) => system.GetGLProcAddress(procName);

		protected override Result<void, String> Initialize()
		{
			if (!(Core.System is ISystemOpenGL)) return .Err("System must be present and support openGL");
			system = Core.System as ISystemOpenGL;
			
			GL.Init(=> GetProcAddress);

			GL.glEnable(GL.GL_DEBUG_OUTPUT);
			GL.glEnable(GL.GL_DEBUG_OUTPUT_SYNCHRONOUS);

			GL.glDebugMessageCallback(=> DebugCallback, null);
			GL.glGetIntegerv(GL.GL_MAX_TEXTURE_SIZE, &maxTextureSize);
			return .Ok;
		}

		static void DebugCallback(uint source, uint type, uint id, uint severity, int length, char8* message, void* userParam)
		{
			if (severity != GL.GL_DEBUG_SEVERITY_HIGH && severity != GL.GL_DEBUG_SEVERITY_MEDIUM && severity != GL.GL_DEBUG_SEVERITY_LOW) return;

			var s = scope String("OpenGL ");

			switch (type)
			{
			case GL.GL_DEBUG_TYPE_ERROR: s.Append("ERROR");
			case GL.GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: s.Append("DEPRECATED BEHAVIOR");
			case GL.GL_DEBUG_TYPE_MARKER: s.Append("MARKER");
			case GL.GL_DEBUG_TYPE_OTHER: s.Append("OTHER");
			case GL.GL_DEBUG_TYPE_PERFORMANCE: s.Append("PEROFRMANCE");
			case GL.GL_DEBUG_TYPE_POP_GROUP: s.Append("POP GROUP");
			case GL.GL_DEBUG_TYPE_PORTABILITY: s.Append("PORTABILITY");
			case GL.GL_DEBUG_TYPE_PUSH_GROUP: s.Append("PUSH GROUP");
			case GL.GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: s.Append("UNDEFINED BEHAVIOR");
			default: s.Append("UNKNOWN");
			}

			s.Append(", ");

			switch (severity)
			{
			case GL.GL_DEBUG_SEVERITY_HIGH: s.Append("HIGH");
			case GL.GL_DEBUG_SEVERITY_MEDIUM: s.Append("MEDIUM");
			case GL.GL_DEBUG_SEVERITY_LOW: s.Append("LOW");
			}

			s.Append(": ");

			// Add message
			String.QuoteString(message, length, s);

			Console.WriteLine(s);
		}

		protected override void Update()
		{

		}

		protected override void AfterRender()
		{

		}
	}
}
