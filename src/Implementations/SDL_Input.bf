using SDL2;
using System;
using System.Collections;

namespace Pile.Implementations
{
	public class SDL_Input : Input
	{
		readonly SDL.SDL_Cursor*[] sdlCursors;
		readonly SDL.SDL_Joystick*[] sdlJoysticks;
		readonly SDL.SDL_GameController*[] sdlGamepads;
		readonly SDL_Window window; // deleted by Core

		public this(SDL_Window window)
		{
			this.window = window;

			sdlCursors = new SDL.SDL_Cursor*[(int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZEALL];
			sdlJoysticks = new SDL.SDL_Joystick*[maxControllers];
			sdlGamepads = new SDL.SDL_GameController*[maxControllers];
		}	

		public ~this()
		{
			for (int i = 0; i < sdlCursors.Count; i++)
			{
				if (sdlCursors[i] != null)
					SDL.FreeCursor(sdlCursors[i]);
				delete sdlCursors[i];
			}
			delete sdlCursors;

			delete sdlJoysticks;
			delete sdlGamepads;
		}

		public override void SetMouseCursor(Cursors cursor)
		{
			int index = 0;
			switch (cursor)
			{
			case .Default: index = (int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_ARROW;
			case .IBeam: index = (int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_IBEAM;
			case .Crosshair: index = (int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_CROSSHAIR;
			case .Hand: index = (int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_HAND;
			case .HorizontalResize: index = (int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZEWE;
			case .VerticalResize: index = (int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZENS;
			case .Forbidden: index = (int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_NO;
			}

			if (sdlCursors[index] == null)
				sdlCursors[index] = SDL.CreateSystemCursor((SDL.SDL_SystemCursor)index);

			SDL.SetCursor(sdlCursors[index]);
		}

		public override void SetClipboardString(System.String value)
		{
			SDL.SetClipboardText(value);
		}

		public override void GetClipboardString(System.String buffer)
		{
			if (SDL.HasClipboardText() == SDL.Bool.True)
				buffer.Append(SDL.GetClipboardText());
		}

		public override Point MousePosition
		{
			get
			{
				SDL.GetWindowPosition(window.[Friend]window, let winX, let winY);
				int32 x = 0, y = 0;
				SDL.GetGlobalMouseState(&x, &y);
				return Point(x - winX, y - winY);
			}

			set =>SDL.WarpMouseInWindow(window.[Friend]window, (int32)value.X, (int32)value.Y);
		}

		void ProcessEvent(SDL.Event e)
		{
			switch (e.type)
			{
				// Mouse events
			case .MouseButtonDown:
				switch (e.button.button)
				{
				case SDL.SDL_BUTTON_LEFT: OnMouseDown(.Left);
				case SDL.SDL_BUTTON_RIGHT: OnMouseDown(.Right);
				case SDL.SDL_BUTTON_MIDDLE: OnMouseDown(.Middle);
				case SDL.SDL_BUTTON_X1: OnMouseDown(.Extra1);
				case SDL.SDL_BUTTON_X2: OnMouseDown(.Extra2);
				default: OnMouseDown(.Unknown);
				}
			case .MouseButtonUp:
				switch (e.button.button)
				{
				case SDL.SDL_BUTTON_LEFT: OnMouseUp(.Left);
				case SDL.SDL_BUTTON_RIGHT: OnMouseUp(.Right);
				case SDL.SDL_BUTTON_MIDDLE: OnMouseUp(.Middle);
				case SDL.SDL_BUTTON_X1: OnMouseUp(.Extra1);
				case SDL.SDL_BUTTON_X2: OnMouseUp(.Extra2);
				default: OnMouseUp(.Unknown);
				}
			case .MouseWheel:
				OnMouseWheel(e.wheel.x, e.wheel.y);
				// Joystick events
			case .JoyDeviceAdded:
				var index = e.jdevice.which;

				if (maxControllers < (uint)index && SDL.IsGameController(index) == SDL.Bool.False)
				{
				    var ptr = sdlJoysticks[index] = SDL.JoystickOpen(index);
				    var buttonCount = SDL.JoystickNumButtons(ptr);
				    var axisCount = SDL.JoystickNumAxes(ptr);

				    OnJoystickConnect((uint)index, (uint)buttonCount, (uint)axisCount, false);
				}
			case .JoyDeviceRemoved:
				var index = e.jdevice.which;

				if (maxControllers < (uint)index && SDL.IsGameController(index) == SDL.Bool.False)
				{
				    OnJoystickDisconnect((uint)index);

				    var ptr = sdlJoysticks[index];
				    sdlJoysticks[index] = null;
				    SDL.JoystickClose(ptr);
				}
			case .JoyButtonDown:
				var index = e.jbutton.which;
				if (SDL.IsGameController(index) == SDL.Bool.False)
				    OnJoystickButtonDown((uint)index, e.jbutton.button);
			case .JoyButtonUp:
				var index = e.jbutton.which;
				if (SDL.IsGameController(index) == SDL.Bool.False)
				    OnJoystickButtonUp((uint)index, e.jbutton.button);
			case .JoyAxisMotion:
				var index = e.jaxis.which;
				if (SDL.IsGameController(index) == SDL.Bool.False)
				{
				    var value = Math.Max(-1f, Math.Min(1f, (int16)e.jaxis.axisValue / (float)Int16.MaxValue));
				    OnJoystickAxis((uint)index, e.jaxis.axis, value);
				}
				// Controller events
			case .ControllerDeviceadded:
				var index = e.cdevice.which;
				sdlGamepads[index] = SDL.GameControllerOpen(index);
				OnJoystickConnect((uint)index, 15, 6, true);
			case .ControllerDeviceremoved:
				var index = e.cdevice.which;
				OnJoystickDisconnect((uint)index);

				var ptr = sdlGamepads[index];
				sdlGamepads[index] = null;
				SDL.GameControllerClose(ptr);
			case .ControllerButtondown:
				var index = e.cbutton.which;
				var button = GamepadButtonToEnum(e.cbutton.button);

				OnGamepadButtonDown((uint)index, button);
			case .ControllerButtonup:
				var index = e.cbutton.which;
				var button = GamepadButtonToEnum(e.cbutton.button);

				OnGamepadButtonUp((uint)index, button);
			case .ControllerAxismotion:
				var index = e.caxis.which;
				var axis = GamepadAxisToEnum(e.caxis.axis);
				var value = Math.Max(-1f, Math.Min(1f, e.caxis.axisValue / (float)Int16.MaxValue));

				OnGamepadAxis((uint)index, axis, value);
				// Key events
			case .KeyDown, .KeyUp:
				if (e.key.isRepeat == 0)
				{
				    var keycode = e.key.keysym.sym;
					Keys key = KeycodeToEnum(keycode);

				    if (e.type == SDL.EventType.KeyDown)
				        OnKeyDown(key);
				    else
				        OnKeyUp(key);
				}
				// Text input events
			case .TextInput:
				int index = 0;
				while (e.text.text[index] != 0)
				    OnText((char16)(e.text.text[index++]));
			default:
			}
		}

		private static Buttons GamepadButtonToEnum(uint8 button)
		{
			Buttons output;
		    switch (button)
		    {
		        case (uint8)SDL.SDL_GameControllerButton.A: output = Buttons.A;
		        case (uint8)SDL.SDL_GameControllerButton.B: output = Buttons.B;
		        case (uint8)SDL.SDL_GameControllerButton.X: output = Buttons.X;
		        case (uint8)SDL.SDL_GameControllerButton.Y: output = Buttons.Y;
		        case (uint8)SDL.SDL_GameControllerButton.Back: output = Buttons.Back;
		        case (uint8)SDL.SDL_GameControllerButton.Guide: output = Buttons.Select;
		        case (uint8)SDL.SDL_GameControllerButton.Start: output = Buttons.Start;
		        case (uint8)SDL.SDL_GameControllerButton.LeftStick: output = Buttons.LeftStick;
		        case (uint8)SDL.SDL_GameControllerButton.RightStick: output = Buttons.RightStick;
		        case (uint8)SDL.SDL_GameControllerButton.LeftShoulder: output = Buttons.LeftShoulder;
		        case (uint8)SDL.SDL_GameControllerButton.RightShoulder: output = Buttons.RightShoulder;
		        case (uint8)SDL.SDL_GameControllerButton.DpadUp: output = Buttons.Up;
		        case (uint8)SDL.SDL_GameControllerButton.DpadDown: output = Buttons.Down;
		        case (uint8)SDL.SDL_GameControllerButton.DpadLeft: output = Buttons.Left;
		        case (uint8)SDL.SDL_GameControllerButton.DpadRight: output = Buttons.Right;
		        default: output = Buttons.Unknown;
		    }
			return output;
		}

		private static Axes GamepadAxisToEnum(uint8 axes)
		{
			Axes output;
		    switch (axes)
		    {
		        case (uint8)SDL.SDL_GameControllerAxis.LeftX: output = Axes.LeftX;
		        case (uint8)SDL.SDL_GameControllerAxis.LeftY: output = Axes.LeftY;
		        case (uint8)SDL.SDL_GameControllerAxis.RightX: output = Axes.RightX;
		        case (uint8)SDL.SDL_GameControllerAxis.TriggerLeft: output = Axes.LeftTrigger;
		        case (uint8)SDL.SDL_GameControllerAxis.TriggerRight: output = Axes.RightTrigger;
		        default: output = Axes.Unknown;
		    }
			return output;
		}

		private static Keys KeycodeToEnum(SDL.Keycode keycode)
		{
			return Keys.Unknown;
		}
	}
}
