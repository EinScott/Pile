using Pile;
using System;
using SDL2;

namespace Pile.Implementations
{
	public class SDL_System : System
	{
		SDL_Window window; // Is managed by Core
		SDL_Input input;

		public this()
		{
			SDL_Init.[Friend]InitFlags |= .Video | .Joystick | .GameController | .Events;
		}

		public ~this()
		{

		}

		protected override Input CreateInput()
		{
			return input = new SDL_Input(window);
		}

		protected override Window CreateWindow(int width, int height)
		{
			return window = new SDL_Window(Core.Title, width, height);
		}

		protected override void Initialize()
		{
			SDL_Init.[Friend]Init();
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
					if (event.window.windowID == window.[Friend]windowID)
					{
						switch (event.window.windowEvent)
						{
						case .Close:
							Core.Exit();
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
