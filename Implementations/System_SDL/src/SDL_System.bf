using Pile;
using System;
using SDL2;

namespace Pile.Implementations
{
	public class SDL_System : System, ISystemOpenGL
	{
		public override String ApiName => "SDL2";

		SDL_Window window; // Are both managed by Core
		SDL_Input input;
		
		bool glGraphics;

		public this()
		{
			SDL_Init.[Friend]InitFlags |= .Video | .Joystick | .GameController | .Events;
		}

		protected override Input CreateInput()
		{
			// Only one input
			if (input == null) return input = new .(window);
			else return input;
		}

		protected override Window CreateWindow(int32 width, int32 height)
		{
			// Only one window
			if (window == null)
			{
				window = new [Friend].(Core.Title, width, height, this);

				return window;
			}
			else return window;
		}

		protected override void Initialize()
		{
			SDL_Init.[Friend]Init();

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

		protected override void Update()
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
					if (!window.Closed && event.window.windowID == window.[Friend]windowID)
					{
						switch (event.window.windowEvent)
						{
						case .Close:
							window.OnClose();
							window.[Friend]Closed = true;
							return;

						case .SizeChanged: // Preceeds .Resize, is always triggered when size changes
							window.OnResized();

						// Size
						case .Resized: // Only resize through external causes
							window.[Friend]size.X = event.window.data1;
							window.[Friend]size.Y = event.window.data2;
							window.OnUserResized();
		
						// Moved
						case .Moved:
							window.[Friend]position.X = event.window.data1;
							window.[Friend]position.Y = event.window.data2;
							window.OnMoved();
		
						// Focus
						case .TAKE_FOCUS:
							SDL.SDL_SetWindowInputFocus(window.[Friend]window); // Take focus
						case .FocusGained:
							window.[Friend]focus = true;
							window.OnFocusChanged();
						case .Focus_lost:
							window.[Friend]focus = false;
							window.OnFocusChanged();
		
						// Visible
						case .Restored, .Shown, .Maximized:
							window.[Friend]visible = true;
							window.OnVisibilityChanged();
						case .Hidden, .Minimized:
							window.[Friend]visible = false;
							window.OnVisibilityChanged();

						// MouseOver
						case .Enter:
							window.[Friend]mouseFocus = true;
						case .Leave:
							window.[Friend]mouseFocus = false;
						default:
						}
					}
				case .KeyDown, .KeyUp, .TextEditing, .TextInput, .KeyMapChanged,
					 .MouseButtonDown, .MouseButtonUp, .MouseWheel,
					 .JoyAxisMotion, .JoyBallMotion, .JoyButtonDown, .JoyButtonUp, .JoyDeviceAdded, .JoyDeviceRemoved, .JoyHatMotion,
					 .ControllerAxismotion, .ControllerButtondown, .ControllerButtonup, .ControllerDeviceadded, .ControllerDeviceremapped, .ControllerDeviceremoved:
					input.[Friend]ProcessEvent(event);
				default:
				}

				if (*SDL.GetError() != '\0')
				{
					Log.Warning(scope String("SDL error while processing event {0}: {1}")..Format(event.type, scope String(SDL.GetError())));
					SDL.ClearError();
				}
			}
		}

		[Hide]
		public void* GetGLProcAddress(StringView procName)
		{
			return SDL.SDL_GL_GetProcAddress(procName.ToScopeCStr!());
		}

		[Hide]
		public void SetGLAttributes(uint32 depthSize, uint32 stencilSize, uint32 multisamplerBuffers, uint32 multisamplerSamples)
		{
			SDL.GL_SetAttribute(.GL_DEPTH_SIZE, depthSize);
			SDL.GL_SetAttribute(.GL_STENCIL_SIZE, stencilSize);
			SDL.GL_SetAttribute(.GL_MULTISAMPLEBUFFERS, multisamplerBuffers);
			SDL.GL_SetAttribute(.GL_MULTISAMPLESAMPLES, multisamplerSamples);
		}

		public ISystemOpenGL.Context GetGLContext()
		{
			return window.[Friend]context;
		}
	}
}
