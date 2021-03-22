using Pile;
using System;
using static SDL2.SDL;

using internal Pile;

namespace Pile
{
	extension System
	{
		public static override String ApiName => "SDL2";
		
		static String info = new String() ~ delete _;
		public static override String Info => info;

#if BF_PLATFORM_WINDOWS 
		[Import("user32.lib"), CLink, CallingConvention(.Stdcall)]
		static extern bool SetProcessDPIAware();
#endif

		static this()
		{
			// Version
			GetVersion(let ver);
			MajorVersion = ver.major;
			MinorVersion = ver.minor;
			info.AppendF("patch: {}", ver.patch);
		}

		protected internal static override void Initialize()
		{
#if BF_PLATFORM_WINDOWS 
			if (Environment.OSVersion.Platform == PlatformID.Win32NT)
				SetProcessDPIAware();
#endif

			Init(.Video | .Joystick | .GameController | .Events);

			if (Graphics.Renderer.IsOpenGL)
			{
				GL_SetAttribute(.GL_CONTEXT_MAJOR_VERSION, (int32)Graphics.MajorVersion);
				GL_SetAttribute(.GL_CONTEXT_MINOR_VERSION, (int32)Graphics.MinorVersion);
				GL_SetAttribute(.GL_CONTEXT_PROFILE_MASK, Graphics.Renderer == .OpenGLCore ? SDL_GLProfile.GL_CONTEXT_PROFILE_CORE : SDL_GLProfile.GL_CONTEXT_PROFILE_ES);
				GL_SetAttribute(.GL_CONTEXT_FLAGS, (int32)SDL_GLContextFlags.GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
				GL_SetAttribute(.GL_DOUBLEBUFFER, 1);

				if (Graphics.Renderer == .OpenGLCore)
					RendererSupport = .OpenGLCore(=> GetGLProcAddress, => SetGLAttributes);
				else Runtime.NotImplemented(); // TODO
			}

			// Displays
			let numDisplays = SDL_GetNumVideoDisplays();
			for (int32 i = 0; i < numDisplays; i ++)
			    monitors.Add(new Monitor(i));
		}

		protected internal static override void Destroy()
		{
			Quit();
		}

		protected internal static override void Step()
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
					if (!Window.Closed && event.window.windowID == Window.windowID)
					{
						switch (event.window.windowEvent)
						{
						case .Close:
							Window.OnClose();
							Window.Closed = true;
							return;

						case .SizeChanged: // Precedes .Resize, is always triggered when size changes
							Window.OnResized();

						// Size
						case .Resized: // Only re-size through external causes
							Window.size.X = (.)event.window.data1;
							Window.size.Y = (.)event.window.data2;
							Window.OnUserResized();
		
						// Moved
						case .Moved:
							Window.position.X = event.window.data1;
							Window.position.Y = event.window.data2;
							Window.OnMoved();
		
						// Focus
						case .TAKE_FOCUS:
							SDL_SetWindowInputFocus(Window.window); // Take focus
						case .FocusGained:
							Window.focus = true;
							Window.OnFocusChanged();
						case .Focus_lost:
							Window.focus = false;
							Window.OnFocusChanged();
		
						// Visible
						case .Restored, .Shown, .Maximized:
							Window.visible = true;
							Window.OnVisibilityChanged();
						case .Hidden, .Minimized:
							Window.visible = false;
							Window.OnVisibilityChanged();

						// MouseOver
						case .Enter:
							Window.mouseFocus = true;
						case .Leave:
							Window.mouseFocus = false;
						default:
						}
					}
				case .KeyDown, .KeyUp, .TextEditing, .TextInput, .KeyMapChanged,
					 .MouseButtonDown, .MouseButtonUp, .MouseWheel,
					 .JoyAxisMotion, .JoyBallMotion, .JoyButtonDown, .JoyButtonUp, .JoyDeviceAdded, .JoyDeviceRemoved, .JoyHatMotion,
					 .ControllerAxismotion, .ControllerButtondown, .ControllerButtonup, .ControllerDeviceadded, .ControllerDeviceremapped, .ControllerDeviceremoved:
					Input.ProcessEvent(event);
				default:
				}

				if (*GetError() != '\0')
				{
					Log.Warn(scope $"SDL error while processing event {event.type}: {StringView(GetError())}");
					ClearError();
				}
			}
		}

		static void* GetGLProcAddress(StringView procName)
		{
			return SDL_GL_GetProcAddress(procName.ToScopeCStr!());
		}

		static void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples)
		{
			GL_SetAttribute(.GL_DEPTH_SIZE, (int32)depthSize);
			GL_SetAttribute(.GL_STENCIL_SIZE, (int32)stencilSize);
			GL_SetAttribute(.GL_MULTISAMPLEBUFFERS, (int32)multisamplerBuffers);
			GL_SetAttribute(.GL_MULTISAMPLESAMPLES, (int32)multisamplerSamples);
		}
	}
}
