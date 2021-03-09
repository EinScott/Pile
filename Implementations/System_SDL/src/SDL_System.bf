using Pile;
using System;
using static SDL2.SDL;

using internal Pile;

namespace Pile
{
	extension System : ISystemOpenGL
	{
		uint32 majVer;
		uint32 minVer;
		public override uint32 MajorVersion => majVer;
		public override uint32 MinorVersion => minVer;
		public override String ApiName => "SDL2";

		String info = new String() ~ delete _;
		public override String Info => info;
		
		internal bool glGraphics;

#if BF_PLATFORM_WINDOWS 
		[Import("user32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern bool SetProcessDPIAware();
#endif

		protected internal override void Initialize()
		{
#if BF_PLATFORM_WINDOWS 
			if (Environment.OSVersion.Platform == PlatformID.Win32NT)
				SetProcessDPIAware();
#endif

			Init(.Video | .Joystick | .GameController | .Events);

			// Version
			GetVersion(let ver);
			majVer = ver.major;
			minVer = ver.minor;

			info.AppendF("patch: {}", ver.patch);

			if (Core.Graphics is IGraphicsOpenGL)
			{
				GL_SetAttribute(.GL_CONTEXT_MAJOR_VERSION, (int32)Core.Graphics.MajorVersion);
				GL_SetAttribute(.GL_CONTEXT_MINOR_VERSION, (int32)Core.Graphics.MinorVersion);
				GL_SetAttribute(.GL_CONTEXT_PROFILE_MASK, (int32)(Core.Graphics as IGraphicsOpenGL).Profile);
				GL_SetAttribute(.GL_CONTEXT_FLAGS, (int32)SDL_GLContextFlags.GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
				GL_SetAttribute(.GL_DOUBLEBUFFER, 1);
				glGraphics = true;
			}

			// Displays
			let numDisplays = SDL_GetNumVideoDisplays();
			for (int32 i = 0; i < numDisplays; i ++)
			    monitors.Add(new Monitor(i));
		}

		internal ~this()
		{
			Quit();
		}

		protected internal override void Step()
		{
			Event event;
			while (PollEvent(out event) != 0)
			{
				switch (event.type)
				{
				case .Quit:
					Core.Exit();
					return;
				case .WindowEvent:
					if (!Core.Window.Closed && event.window.windowID == Core.Window.windowID)
					{
						switch (event.window.windowEvent)
						{
						case .Close:
							Core.Window.OnClose();
							Core.Window.Closed = true;
							return;

						case .SizeChanged: // Preceeds .Resize, is always triggered when size changes
							Core.Window.OnResized();

						// Size
						case .Resized: // Only resize through external causes
							Core.Window.size.X = (.)event.window.data1;
							Core.Window.size.Y = (.)event.window.data2;
							Core.Window.OnUserResized();
		
						// Moved
						case .Moved:
							Core.Window.position.X = event.window.data1;
							Core.Window.position.Y = event.window.data2;
							Core.Window.OnMoved();
		
						// Focus
						case .TAKE_FOCUS:
							SDL_SetWindowInputFocus(Core.Window.window); // Take focus
						case .FocusGained:
							Core.Window.focus = true;
							Core.Window.OnFocusChanged();
						case .Focus_lost:
							Core.Window.focus = false;
							Core.Window.OnFocusChanged();
		
						// Visible
						case .Restored, .Shown, .Maximized:
							Core.Window.visible = true;
							Core.Window.OnVisibilityChanged();
						case .Hidden, .Minimized:
							Core.Window.visible = false;
							Core.Window.OnVisibilityChanged();

						// MouseOver
						case .Enter:
							Core.Window.mouseFocus = true;
						case .Leave:
							Core.Window.mouseFocus = false;
						default:
						}
					}
				case .KeyDown, .KeyUp, .TextEditing, .TextInput, .KeyMapChanged,
					 .MouseButtonDown, .MouseButtonUp, .MouseWheel,
					 .JoyAxisMotion, .JoyBallMotion, .JoyButtonDown, .JoyButtonUp, .JoyDeviceAdded, .JoyDeviceRemoved, .JoyHatMotion,
					 .ControllerAxismotion, .ControllerButtondown, .ControllerButtonup, .ControllerDeviceadded, .ControllerDeviceremapped, .ControllerDeviceremoved:
					Core.Input.ProcessEvent(event);
				default:
				}

				if (*GetError() != '\0')
				{
					Log.Warn(scope $"SDL error while processing event {event.type}: {StringView(GetError())}");
					ClearError();
				}
			}
		}

		[NoShow]
		public void* GetGLProcAddress(StringView procName)
		{
			return SDL_GL_GetProcAddress(procName.ToScopeCStr!());
		}

		[NoShow]
		public void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples)
		{
			GL_SetAttribute(.GL_DEPTH_SIZE, (int32)depthSize);
			GL_SetAttribute(.GL_STENCIL_SIZE, (int32)stencilSize);
			GL_SetAttribute(.GL_MULTISAMPLEBUFFERS, (int32)multisamplerBuffers);
			GL_SetAttribute(.GL_MULTISAMPLESAMPLES, (int32)multisamplerSamples);
		}

		public ISystemOpenGL.Context GetGLContext()
		{
			return Core.Window.context;
		}
	}
}
