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
				else Runtime.NotImplemented();
			}

			// Displays
			let numDisplays = SDL_GetNumVideoDisplays();
			for (int32 i = 0; i < numDisplays; i ++)
			    displays.Add(new Display(i));
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
							if (Window.OnClose.HasListeners)
								Window.OnClose();
							Window.Closed = true;
							return;

						case .SizeChanged: // Precedes .Resized, is always triggered when size changes
							if (Window.OnResized.HasListeners)
								Window.OnResized();

						// Size
						case .Resized: // Only re-size through external causes
							if (Window.OnUserResized.HasListeners)
								Window.OnUserResized();
		
						// Moved
						case .Moved:
							if (Window.OnMoved.HasListeners)
								Window.OnMoved();
		
						// Focus
						case .TAKE_FOCUS:
							SDL_SetWindowInputFocus(Window.window); // Take focus
						case .FocusGained:
							if (Window.OnFocusChanged.HasListeners)
								Window.OnFocusChanged();
						case .Focus_lost:
							if (Window.OnFocusChanged.HasListeners)
								Window.OnFocusChanged();
		
						// Visible
						case .Restored, .Shown, .Maximized:
							Window.visible = true;
							if (Window.OnVisibilityChanged.HasListeners)
								Window.OnVisibilityChanged();
						case .Hidden, .Minimized:
							Window.visible = false;
							if (Window.OnVisibilityChanged.HasListeners)
								Window.OnVisibilityChanged();

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
