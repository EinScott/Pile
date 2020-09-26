using Pile;
using SDL2;
using System;

namespace Pile.Implementations
{
	public class SDL_Window : Window
	{
		SDL_System system;
		SDL.Window* window;
		uint32 windowID;

		SDL_Context context = null;

		protected this(String title, int32 width, int32 height, SDL_System system)
		{
			this.system = system;

			SDL.WindowFlags flags = .Shown | .AllowHighDPI;
			if (system.[Friend]glGraphics) flags |= .OpenGL;

			window = SDL.CreateWindow(title, .Centered, .Centered, width, height, flags);
			windowID = SDL.GetWindowID(window);

			// Set current values
			SDL.GetWindowPosition(window, let px, let py);
			position.Set(px, py);

			size.Set(width, height);

			if (system.[Friend]glGraphics)
			{
				context = new [Friend].(this);

				if (*SDL.GetError() != '\0')
					Console.WriteLine(scope .(SDL.GetError()));
			}
		}

		public ~this()
		{
			CloseInternal();
		}

		protected override void CloseInternal()
		{
			SDL.DestroyWindow(window);
			if (system.[Friend]glGraphics && context != null)
			{
				delete context;
				context = null;
			}
		}

		public override void SetTitle(StringView title) => SDL.SetWindowTitle(window, scope String(title));
		public override void GetTitle(String buffer) => buffer.Append(SDL.GetWindowTitle(window));

		Point2 position;
		public override Point2 Position
		{
			get => position;

			set
			{
				if (value != position)
				{
					SDL.SetWindowPosition(window, (int32)value.X, (int32)value.Y);
					position = value;
				}
			}
		}

		Point2 size;
		public override Point2 Size
		{
			get => size;

			set
			{
				if (value != size)
				{
					SDL.SetWindowSize(window, (int32)value.X, (int32)value.Y);
					size = value;
				}
			}
		}

		public override Point2 RenderSize
		{
			get
			{
				int32 w = 0, h = 0;

				if (system.[Friend]glGraphics)
					SDL.GL_GetDrawableSize(window, out w, out h);
				else
					SDL.GetWindowSize(window, out w, out h);

				return Point2(w, h);
			}
		}

		public override Vector2 ContentScale
		{
			get
			{
				float hidpiRes = 72f;
				/*if (Environment.OSVersion.Platform == PlatformID.Win32NT)
				    hidpiRes = 96;*/

				int32 index = (int32)SDL.SDL_GetWindowDisplayIndex(window);
				SDL.GetDisplayDPI(index, let ddpi, let _hdpi, let _vdpi);
				return Vector2.One * (ddpi / hidpiRes);
			}
		}

		bool resizable;
		public override bool Resizable
		{
			get => resizable;

			set
			{
				if (value != resizable)
					SDL.SetWindowResizable(window, resizable = value);
			}
		}

		bool fullscreen;
		public override bool Fullscreen
		{
			get => fullscreen;

			set
			{
				if (value != fullscreen)
					SDL.SetWindowFullscreen(window, (fullscreen = value) ? (uint)SDL.WindowFlags.FullscreenDesktop : 0);
			}
		}

		bool bordered = true;
		public override bool Bordered
		{
			get => bordered;

			set
			{
				if (value != bordered)
					SDL.SetWindowBordered(window, bordered = value);
			}
		}

		bool transparent;
		public override bool Transparent
		{
			get => transparent;

			set
			{
				if (value != transparent)
					SDL.SetWindowOpacity(window, (transparent = value) ? 0 : 1);
			}
		}

		bool visible;
		public override bool Visible
		{
			get => visible;

			set
			{
				if (value != visible)
				{
					if (visible = value)
						SDL.ShowWindow(window);
					else
						SDL.HideWindow(window);
				}
			}
		}

		bool vSync = true;
		public override bool VSync
		{
			get => vSync;
			set
			{
				vSync = value;

				if (system.[Friend]glGraphics) SDL.GL_SetSwapInterval(vSync ? 1 : 0);
			}
		}

		bool focus;
		public override bool Focus
		{
			get => focus;
		}

		bool mouseFocus;
		public override bool MouseOver
		{
			get => mouseFocus;
		}

		public override void Focus()
		{
			SDL.RaiseWindow(window);
		}

		protected override void Present()
		{
			if (system.[Friend]glGraphics)
			{
				SDL.GL_SwapWindow(window);
			}
		}
	}
}
