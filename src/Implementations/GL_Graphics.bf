using OpenGL46;
using System;

namespace Pile.Implementations
{
	public class GL_Graphics : Graphics, IGraphicsOpenGL
	{
		public IGraphicsOpenGL.GLProfile Profile
		{
			get
			{
				//GL.glGetIntegerv(GL.GL_CONTEXT_CORE_PROFILE_BIT, )
				return IGraphicsOpenGL.GLProfile.Core;
			}
		}

		int32 majorVersion = 0;
		public override int32 MajorVersion
		{
			get => majorVersion;
		}

		int32 minorVersion = 0;
		public override int32 MinorVersion
		{
			get => minorVersion;
		}

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
			
			system.CreateGLContext();
			GL.Init(=> GetProcAddress);

			Console.WriteLine(GetProcAddress("glDebugMessageCallback"));
			Console.WriteLine(scope String(SDL2.SDL.GetError()));
			//GL.glDebugMessageCallback(=> DebugCallback, null);
			GL.glGetIntegerv(GL.GL_MAX_TEXTURE_SIZE, &maxTextureSize);
			GL.glGetIntegerv(GL.GL_MINOR_VERSION, &minorVersion);
			GL.glGetIntegerv(GL.GL_MAJOR_VERSION, &majorVersion);
			
			return .Ok;
		}

		static void DebugCallback(uint source, uint type, uint id, uint severity, int length, char8* message, void* userParam)
		{
			Console.WriteLine("m");
		}

		protected override void Update()
		{

		}

		protected override void AfterRender()
		{

		}
	}
}
