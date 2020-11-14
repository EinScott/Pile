using Pile;
using System;
using SDL2;

using internal Pile;

namespace Pile.Implementations
{
	public class SDL_System : System, ISystemOpenGL
	{
		uint32 majVer;
		uint32 minVer;
		public override uint32 MajorVersion => majVer;
		public override uint32 MinorVersion => minVer;
		public override String ApiName => "SDL2";

		String info = new String() ~ delete _;
		public override String Info => info;

		SDL_Window window; // Are both managed by Core
		SDL_Input input;
		
		internal bool glGraphics;

#if BF_PLATFORM_WINDOWS 
		[Import("user32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern bool SetProcessDPIAware();
#endif

		public this()
		{
			SDL_Init.InitFlags |= .Video | .Joystick | .GameController | .Events;
		}

		internal override Input CreateInput()
		{
			// Only one input
			if (input == null) return input = new .(window);
			else return input;
		}

		internal override Window CreateWindow(int32 width, int32 height)
		{
			// Only one window
			if (window == null)
			{
				window = new SDL_Window(Core.Title, width, height, this);

				return window;
			}
			else return window;
		}

		internal override void Initialize()
		{
#if BF_PLATFORM_WINDOWS 
			if (Environment.OSVersion.Platform == PlatformID.Win32NT)
				SetProcessDPIAware();
#endif

			SDL_Init.Init();

			// Version
			SDL.GetVersion(let ver);
			majVer = ver.major;
			minVer = ver.minor;

			info.AppendF("patch: {}", ver.patch);

			if (Core.Graphics is IGraphicsOpenGL)
			{
				SDL.GL_SetAttribute(.GL_CONTEXT_MAJOR_VERSION, Core.Graphics.MajorVersion);
				SDL.GL_SetAttribute(.GL_CONTEXT_MINOR_VERSION, Core.Graphics.MinorVersion);
				SDL.GL_SetAttribute(.GL_CONTEXT_PROFILE_MASK, (uint32)(Core.Graphics as IGraphicsOpenGL).Profile);
				SDL.GL_SetAttribute(.GL_CONTEXT_FLAGS, (uint32)SDL.SDL_GLContextFlags.GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
				SDL.GL_SetAttribute(.GL_DOUBLEBUFFER, 1);
				glGraphics = true;
			}
		}

		internal override void Step()
		{
			SDL.Event event;
			while (SDL.PollEvent(out event) != 0)
			{
				switch (event.type)
				{
				case .Quit:
					Core.Exit();
					return;
				case .WindowEvent:
					if (!window.Closed && event.window.windowID == window.windowID)
					{
						switch (event.window.windowEvent)
						{
						case .Close:
							window.OnClose();
							window.Closed = true;
							return;

						case .SizeChanged: // Preceeds .Resize, is always triggered when size changes
							window.OnResized();

						// Size
						case .Resized: // Only resize through external causes
							window.size.X = event.window.data1;
							window.size.Y = event.window.data2;
							window.OnUserResized();
		
						// Moved
						case .Moved:
							window.position.X = event.window.data1;
							window.position.Y = event.window.data2;
							window.OnMoved();
		
						// Focus
						case .TAKE_FOCUS:
							SDL.SDL_SetWindowInputFocus(window.window); // Take focus
						case .FocusGained:
							window.focus = true;
							window.OnFocusChanged();
						case .Focus_lost:
							window.focus = false;
							window.OnFocusChanged();
		
						// Visible
						case .Restored, .Shown, .Maximized:
							window.visible = true;
							window.OnVisibilityChanged();
						case .Hidden, .Minimized:
							window.visible = false;
							window.OnVisibilityChanged();

						// MouseOver
						case .Enter:
							window.mouseFocus = true;
						case .Leave:
							window.mouseFocus = false;
						default:
						}
					}
				case .KeyDown, .KeyUp, .TextEditing, .TextInput, .KeyMapChanged,
					 .MouseButtonDown, .MouseButtonUp, .MouseWheel,
					 .JoyAxisMotion, .JoyBallMotion, .JoyButtonDown, .JoyButtonUp, .JoyDeviceAdded, .JoyDeviceRemoved, .JoyHatMotion,
					 .ControllerAxismotion, .ControllerButtondown, .ControllerButtonup, .ControllerDeviceadded, .ControllerDeviceremapped, .ControllerDeviceremoved:
					input.ProcessEvent(event);
				default:
				}

				if (*SDL.GetError() != '\0')
				{
					Log.Warning(scope $"SDL error while processing event {event.type}: {StringView(SDL.GetError())}");
					SDL.ClearError();
				}
			}
		}

		[NoShow]
		public void* GetGLProcAddress(StringView procName)
		{
			return SDL.SDL_GL_GetProcAddress(procName.ToScopeCStr!());
		}

		[NoShow]
		public void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples)
		{
			SDL.GL_SetAttribute(.GL_DEPTH_SIZE, depthSize);
			SDL.GL_SetAttribute(.GL_STENCIL_SIZE, stencilSize);
			SDL.GL_SetAttribute(.GL_MULTISAMPLEBUFFERS, multisamplerBuffers);
			SDL.GL_SetAttribute(.GL_MULTISAMPLESAMPLES, multisamplerSamples);
		}

		public ISystemOpenGL.Context GetGLContext()
		{
			return window.context;
		}
	}
}
