using Pile;
using SDL2;
using System;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	extension Window
	{
		internal SDL.Window* window;
		internal uint32 windowID;

		internal SDL.SDL_GLContext context;
		bool isGL;

		protected internal override void Initialize(StringView name, uint32 width, uint32 height, WindowState state, bool hidden)
		{
			SDL.WindowFlags sdlFlags = .Shown | .AllowHighDPI;
			if (Graphics.Renderer.IsOpenGL) sdlFlags |= .OpenGL;
			if (hidden)
			{
				sdlFlags |= .Hidden;
				visible = false;
			}

			switch (state)
			{
			case .Windowed:
			case .WindowedBorderless:
				sdlFlags |= .Borderless;
				bordered = false;
			case .Maximized:
				sdlFlags |= .Maximized;
			case .Fullscreen:
				sdlFlags |= .FullscreenDesktop;
				fullscreen = true;
			}

			window = SDL.CreateWindow(scope String(name).CStr(), .Centered, .Centered, (.)width, (.)height, sdlFlags);
			windowID = SDL.GetWindowID(window);

			// Set current values
			SDL.GetWindowPosition(window, let px, let py);
			position = .(px, py);

			size = .(width, height);

			// Scale to dpi
			float hidpiRes = 72f;
			if (Environment.OSVersion.Platform == PlatformID.Win32NT)
			    hidpiRes = 96;

			int32 index = (int32)SDL.SDL_GetWindowDisplayIndex(window);
			SDL.GetDisplayDPI(index, let ddpi, ?, ?);
			let dpi = (ddpi / hidpiRes);

			if (dpi != 1)
			{
				SDL.GetDesktopDisplayMode(index, let displayMode);
				SDL.SetWindowPosition(window, (int32)(displayMode.w - width * dpi) / 2, (int32)(displayMode.h - height * dpi) / 2);
				SDL.SetWindowSize(window, (int32)(width * dpi), (int32)(height * dpi));
			}

			// Create graphics context
			if (Graphics.Renderer.IsOpenGL)
			{
				context = SDL.GL_CreateContext(window);
				isGL = true;
			}

			if (*SDL.GetError() != '\0')
				Runtime.FatalError(scope $"Error while creating window: {StringView(SDL.GetError())}");
		}

		public override Result<void> SetIcon(Bitmap bitmap)
		{
			// When "Color" implicitly converts to uint32, the masks would be the opposite.
			// But since we'll be looking at the raw struct data layout when passing this in,
			// it'll have to be this way around
			const uint32 rmask = 0x000000ff;
			const uint32 gmask = 0x0000ff00;
			const uint32 bmask = 0x00ff0000;
			const uint32 amask = 0xff000000;

			if (bitmap != null)
			{
				let iconSurface = SDL.CreateRGBSurfaceFrom(bitmap.Pixels.Ptr, (.)bitmap.Width, (.)bitmap.Height, 32, sizeof(Color) * (.)bitmap.Width, rmask, gmask, bmask, amask);
				if (iconSurface == null)
					LogErrorReturn!("Couldn't set application icon, SDL Surface not created");
	
				SDL.SetWindowIcon(window, iconSurface);
				SDL.FreeSurface(iconSurface);
			}
			return .Ok;
		}

		public ~this()
		{
			CloseInternal();
		}

		protected override void CloseInternal()
		{
			SDL.DestroyWindow(window);
			if (Graphics.Renderer.IsOpenGL && context != 0)
			{
				SDL.GL_DeleteContext(context);
				context = 0;
			}
		}

		public override void* NativeHandle
		{
			get
			{
				var info = SDL.SDL_SysWMinfo();
				SDL.GetWindowWMInfo(window, ref info);

#if BF_PLATFORM_WINDOWS
				if (info.info.winrt.window != null)
					return info.info.winrt.window;
				return (void*)(int)info.info.win.window;
#endif
#if BF_PLATFORM_LINUX
				if (info.info.x11.window != null)
					return info.info.x11.window;
				if (info.info.wl.shell_surface != null)
					return info.info.wl.shell_surface;
				if (info.info.android.window != null)
					return info.info.android.window;
				Log.Error("Native window handle couldn't be retrieved");
				return null;
#endif
#if BF_PLATFORM_MACOS
				return info.info.cocoa.window;
#endif
			}
		}

		public override void SetTitle(StringView title) => SDL.SetWindowTitle(window, scope String(title));
		public override void GetTitle(String buffer) => buffer.Append(SDL.GetWindowTitle(window));

		internal Point2 position;
		public override int X
		{
			get => position.X;
			set
			{
				if (value != position.X)
				{
					position.X = value;
					SDL.SetWindowPosition(window, (int32)position.X, (int32)position.Y);
				}
			}
		}
		public override int Y
		{
			get => position.Y;
			set
			{
				if (value != position.Y)
				{
					position.X = value;
					SDL.SetWindowPosition(window, (int32)position.X, (int32)position.Y);
				}
			}
		}
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

		internal UPoint2 size;
		public override uint Width
		{
			get => size.X;

			set
			{
				if (value != size.X)
				{
					size.X = value;
					SDL.SetWindowSize(window, (int32)position.X, (int32)position.Y);
				}
			}
		}
		public override uint Height
		{
			get => size.Y;

			set
			{
				if (value != size.Y)
				{
					size.Y = value;
					SDL.SetWindowSize(window, (int32)position.X, (int32)position.Y);
				}
			}
		}
		public override UPoint2 Size
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

		UPoint2 minSize;
		public override UPoint2 MinSize
		{
			get => minSize;

			set
			{
				if (value != minSize)
				{
					SDL.SetWindowMinimumSize(window, (int32)value.X, (int32)value.Y);
					minSize = value;
				}
			}
		}

		public override UPoint2 RenderSize
		{
			get
			{
				int32 w = 0, h = 0;

				if (isGL)
					SDL.GL_GetDrawableSize(window, out w, out h);
				else
					SDL.GetWindowSize(window, out w, out h);

				return UPoint2((.)w, (.)h);
			}
		}

		public override Vector2 ContentScale
		{
			get
			{
				float hidpiRes = 72f;
				if (Environment.OSVersion.Platform == PlatformID.Win32NT)
				    hidpiRes = 96;

				int32 index = (int32)SDL.SDL_GetWindowDisplayIndex(window);
				SDL.GetDisplayDPI(index, let ddpi, ?, ?);
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

		internal bool visible = true;
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

				if (isGL) SDL.GL_SetSwapInterval(vSync ? 1 : 0);
			}
		}

		internal bool focus;
		public override bool Focus
		{
			get => focus;
		}

		internal bool mouseFocus;
		public override bool MouseOver
		{
			get => mouseFocus;
		}

		public override Display Display
		{
			get
			{
				int index = SDL.SDL_GetWindowDisplayIndex(window);
				return System.displays[index];
			}
		}	

		public override void SetFocused()
		{
			SDL.RaiseWindow(window);
		}

		protected internal override void Present()
		{
			if (isGL)
			{
				SDL.GL_SwapWindow(window);
			}
		}
	}
}
