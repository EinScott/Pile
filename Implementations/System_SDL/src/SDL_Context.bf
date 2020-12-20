using SDL2;
using System;

using internal Pile;

namespace Pile
{
	public class SDL_Context : ISystemOpenGL.Context
	{
		SDL.SDL_GLContext context;
		Window window;

		internal this(Window window)
		{
			this.window = window;
			context = SDL.GL_CreateContext(window.window);
		}

		internal ~this()
		{
			SDL.GL_DeleteContext(context);
		}

		public override void MakeCurrent()
		{
			SDL.SDL_GL_MakeCurrent(window.window, context);
		}
	}
}
