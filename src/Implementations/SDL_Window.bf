using Pile;
using SDL2;
using System;

namespace Pile.Implementations
{
	public class SDL_Window : Window
	{
		SDL.Window* window;
		uint32 windowID;

		protected this(String title, int width, int height)
		{
			window = SDL.CreateWindow(title, .Centered, .Centered, (int32)width, (int32)height, .Shown | .OpenGL);
			windowID = SDL.GetWindowID(window);

			// Set current values
			SDL.GetWindowPosition(window, let px, let py);
			position.Set(px, py);

			size.Set(width, height);
		}

		public ~this()
		{
			CloseInternal();
		}

		protected override void CloseInternal()
		{
			SDL.DestroyWindow(window);
			((SDL_System)Core.System).[Friend]DeleteGLContext();
		}

		public override void SetTitle(String title) => SDL.SetWindowTitle(window, title);
		public override void GetTitle(String buffer) => buffer.Append(SDL.GetWindowTitle(window));

		Point position;
		public override Point Position
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

		Point size;
		public override Point Size
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

		bool resizable;
		public override bool Resizable
		{
			get => resizable;

			set
			{
				if (value != resizable)
				{
					resizable = value;
					SDL.SetWindowResizable(window, value);
				}
			}
		}

		bool fullscreen;
		public override bool Fullscreen
		{
			get => fullscreen;

			set
			{
				if (value != fullscreen)
				{
					SDL.SetWindowFullscreen(window, value ? (uint)SDL.WindowFlags.FullscreenDesktop : 0);
					fullscreen = value;
				}
			}
		}

		bool bordered = true;
		public override bool Bordered
		{
			get => bordered;

			set
			{
				if (value != bordered)
				{
					SDL.SetWindowBordered(window, value);
					bordered = value;
				}
			}
		}

		bool transparent;
		public override bool Transparent
		{
			get => transparent;

			set
			{
				if (value != transparent)
				{
					SDL.SetWindowOpacity(window, transparent ? 0 : 1);
					transparent = value;
				}
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
					if (value)
						SDL.ShowWindow(window);
					else
						SDL.HideWindow(window);
					visible = value;
				}
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
	}
}
