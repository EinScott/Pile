using Pile;
using System;
using SDL2;

namespace Pile.Implementations
{
	public class SDL_System : System, ISystemOpenGL
	{
		SDL_Window window; // Are both managed by Core
		SDL_Input input;
		SDL.SDL_GLContext context;
		bool hasContext;

		public this()
		{
			SDL_Init.[Friend]InitFlags |= .Video | .Joystick | .GameController | .Events;
		}

		public ~this()
		{
			//DeleteGLContext(); // context *should* be deleted when window is closed
		}

		[Hide]
		public void* GetGLProcAddress(StringView procName)
		{
			return SDL.SDL_GL_GetProcAddress(procName.ToScopeCStr!());
		}

		[Hide]
		public void CreateGLContext()
		{
			if (!hasContext)
			{
				context = SDL.GL_CreateContext(window.[Friend]window);
				//SDL.SDL_GL_MakeCurrent(window.[Friend]window, context); // is already done when creating
			}
		}

		protected void DeleteGLContext()
		{
			if (hasContext)
			{
				hasContext = false;
				SDL.GL_DeleteContext(context);
			}
		}

		protected override Input CreateInput()
		{
			// Only one input
			if (input == null) return input = new SDL_Input(window);
			else return input;
		}

		protected override Window CreateWindow(int width, int height)
		{
			// Only one window
			if (window == null)
			{
				window = new [Friend]SDL_Window(Core.Title, width, height);
				CreateGLContext();

				return window;
			}
			else return window;
		}

		protected override void Initialize()
		{
			SDL_Init.[Friend]Init();

			if (Core.Graphics is IGraphicsOpenGL)
			{
				SDL.GL_SetAttribute(SDL.SDL_GLAttr.GL_CONTEXT_MAJOR_VERSION, Core.Graphics.MajorVersion);
				SDL.GL_SetAttribute(SDL.SDL_GLAttr.GL_CONTEXT_MINOR_VERSION, Core.Graphics.MinorVersion);
				SDL.GL_SetAttribute(SDL.SDL_GLAttr.GL_CONTEXT_PROFILE_MASK, (int32)(Core.Graphics as IGraphicsOpenGL).Profile);
				SDL.GL_SetAttribute(SDL.SDL_GLAttr.GL_CONTEXT_FLAGS, (int32)SDL.SDL_GLContextFlags.GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
				SDL.GL_SetAttribute(SDL.SDL_GLAttr.GL_DOUBLEBUFFER, 1);
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
							window.OnCloseRequested();
							return;
		
						// Size
						case .Resized: // Only resize through external causes
							window.[Friend]size.X = event.window.data1;
							window.[Friend]size.Y = event.window.data2;
							window.OnResized();
		
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

				
			}
		}
	}
}
