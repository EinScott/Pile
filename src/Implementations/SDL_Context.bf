using SDL2;
using System;

namespace Pile.Implementations
{
	public class SDL_Context : ISystemOpenGL.Context
	{
		SDL.SDL_GLContext context;
		SDL_Window window;

		protected this(SDL_Window window)
		{
			this.window = window;
			context = SDL.GL_CreateContext(window.[Friend]window);
		}

		public override void Dispose()
		{
			SDL.GL_DeleteContext(context);
			disposed = true;
		}

		public override void MakeCurrent()
		{
			SDL.SDL_GL_MakeCurrent(window.[Friend]window, context);
		}

		bool disposed;
		public override bool Disposed => disposed;
	}
}
