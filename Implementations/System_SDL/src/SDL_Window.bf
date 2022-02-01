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

			bool doMaximize = false;
			switch (state)
			{
			case .Windowed:
			case .WindowedBorderless:
				sdlFlags |= .Borderless;
				bordered = false;
			case .Maximized:
				doMaximize = true;
			case .Fullscreen:
				sdlFlags |= .FullscreenDesktop;
				fullscreen = true;
			}

			window = SDL.CreateWindow(scope String(name).CStr(), .Centered, .Centered, (.)width, (.)height, sdlFlags);
			windowID = SDL.GetWindowID(window);

			// Scale to dpi
			float hidpiRes
#if BF_PLATFORM_WINDOWS
				= 96f;
#else
				= 72f;
#endif

			int32 index = (int32)SDL.SDL_GetWindowDisplayIndex(window);
			SDL.GetDisplayDPI(index, let ddpi, ?, ?);
			let dpi = (ddpi / hidpiRes);

			if (dpi != 1)
			{
				SDL.GetDesktopDisplayMode(index, let displayMode);
				Position = .((.)(displayMode.w - width * dpi) / 2, (.)(displayMode.h - height * dpi) / 2);
				Size = .((.)(width * dpi), (.)(height * dpi));
			}

			// Maximize after pos and size was possibly changed for hidpi
			if (doMaximize)
				SDL.MaximizeWindow(window);

			// Create graphics context
			if (Graphics.Renderer.IsOpenGL)
			{
				context = SDL.GL_CreateContext(window);
				isGL = true;
			}

			if (*SDL.GetError() != '\0')
				Runtime.FatalError(scope $"Error while creating window: {StringView(SDL.GetError())}");

			// Setup current vals
			{
				SDL.GetWindowMinimumSize(window, let w, let h);
				minSize = .((.)w, (.)h);
			}
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
				SDL.GetVersion(out info.version);
				SDL.GetWindowWMInfo(window, ref info);

#if BF_PLATFORM_WINDOWS
				if (info.info.winrt.window != null)
					return info.info.winrt.window;
				return (void*)(int)info.info.win.window;
#elif BF_PLATFORM_LINUX
				if (info.info.x11.window != null)
					return info.info.x11.window;
				if (info.info.wl.shell_surface != null)
					return info.info.wl.shell_surface;
				if (info.info.android.window != null)
					return info.info.android.window;
				Log.Error("Native window handle couldn't be retrieved");
				return null;
#elif BF_PLATFORM_MACOS
				return info.info.cocoa.window;
#else
				Log.Error("Native window handle couldn't be retrieved. What platform even is this?");
				return null;
#endif
			}
		}

		[Inline]
		public override void SetTitle(StringView title) => SDL.SetWindowTitle(window, scope String(title));
		[Inline]
		public override void GetTitle(String buffer) => buffer.Append(SDL.GetWindowTitle(window));

		public override int X
		{
			[Inline]
			get => SDL.GetWindowPosition(window, .. let _, ?);
			[Inline]
			set => SDL.SetWindowPosition(window, (int32)value, SDL.GetWindowPosition(window, .. let _, ?));
		}
		public override int Y
		{
			[Inline]
			get => SDL.GetWindowPosition(window, ?, .. let _);
			[Inline]
			set => SDL.SetWindowPosition(window, SDL.GetWindowPosition(window, ?, .. let _), (int32)value);
		}
		public override Point2 Position
		{
			[Inline]
			get
			{
				SDL.GetWindowPosition(window, let x, let y);
				return .(x, y);
			}
			[Inline]
			set => SDL.SetWindowPosition(window, (int32)value.X, (int32)value.Y);
		}

		public override uint Width
		{
			[Inline]
			get => (.)SDL.GetWindowSize(window, .. let _, ?);
			[Inline]
			set => SDL.SetWindowSize(window, (int32)value, SDL.GetWindowSize(window, ?, .. let _));
		}
		public override uint Height
		{
			[Inline]
			get => (.)SDL.GetWindowSize(window, ?, .. let _);
			[Inline]
			set => SDL.SetWindowSize(window, SDL.GetWindowSize(window, .. let _, ?), (int32)value);
		}
		public override UPoint2 Size
		{
			[Inline]
			get
			{
				SDL.GetWindowSize(window, let w, let h);
				return .((.)w, (.)h);
			}
			[Inline]
			set => SDL.SetWindowSize(window, (int32)value.X, (int32)value.Y);
		}

		UPoint2 minSize;
		public override UPoint2 MinSize
		{
			[Inline]
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
				int32 w, h;

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
				float hidpiRes
#if BF_PLATFORM_WINDOWS
					= 96f;
#else
					= 72f;
#endif

				int32 index = (int32)SDL.SDL_GetWindowDisplayIndex(window);

				SDL.GetDisplayDPI(index, let ddpi, ?, ?);
				return Vector2.One * (ddpi / hidpiRes);
			}
		}

		bool resizable;
		public override bool Resizable
		{
			[Inline]
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
			[Inline]
			get => fullscreen;
			set
			{
				if (value != fullscreen)
					SDL.SetWindowFullscreen(window, (fullscreen = value) ? (uint32)SDL.WindowFlags.FullscreenDesktop : 0);
			}
		}

		bool bordered = true;
		public override bool Bordered
		{
			[Inline]
			get => bordered;
			set
			{
				if (value != bordered)
					SDL.SetWindowBordered(window, bordered = value);
			}
		}

		float opacity = 1;
		public override float Opacity
		{
			[Inline]
			get => opacity;
			set
			{
				if (value != opacity)
					SDL.SetWindowOpacity(window, Math.Clamp(opacity, 0, 1));
			}
		}

		internal bool visible = true;
		public override bool Visible
		{
			[Inline]
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
			[Inline]
			get => vSync;
			set
			{
				vSync = value;

				if (isGL) SDL.GL_SetSwapInterval(vSync ? 1 : 0);
			}
		}

		bool alwaysOnTop;
		public override bool AlwaysOnTop
		{
			[Inline]
			get => alwaysOnTop;
			set
			{
				if (alwaysOnTop != value)
					SDL.SetWindowAlwaysOnTop(window, alwaysOnTop = value);
			}
		}

		public override bool Focus
		{
			[Inline]
			get => (SDL.GetWindowFlags(window) & (uint)SDL.WindowFlags.InputFocus) != 0;
		}

		public override bool MouseOver
		{
			[Inline]
			get => (SDL.GetWindowFlags(window) & (uint)SDL.WindowFlags.MouseFocus) != 0;
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
			if ((SDL.GetWindowFlags(window) & (uint)SDL.WindowFlags.Minimized) != 0)
				SDL.RestoreWindow(window);
			SDL.RaiseWindow(window);
		}

		public override void FlashWindow(Pile.WindowFlash flash)
		{
			SDL.FlashWindow(window, (.)flash);
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
