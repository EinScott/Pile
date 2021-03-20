using SDL2;
using System;
using System.Collections;

using internal Pile;

namespace Pile
{
	extension Input
	{
		bool cursorHidden;
		SDL.SDL_Cursor*[] sdlCursors;
		SDL.SDL_Joystick*[] sdlJoysticks;
		SDL.SDL_GameController*[] sdlGamepads;

		protected internal override void Initialize()
		{
			sdlCursors = new SDL.SDL_Cursor*[(int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZEALL];
			sdlJoysticks = new SDL.SDL_Joystick*[maxControllers];
			sdlGamepads = new SDL.SDL_GameController*[maxControllers];
		}

		internal ~this()
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

		public override void SetControllerRumbleInternal(int index, float leftMotor, float rightMotor, uint duration)
		{
			if (sdlGamepads[index] != null)
			{
				SDL.GameControllerRumble(sdlGamepads[index], (.)(leftMotor * uint16.MaxValue), (.)(rightMotor * uint16.MaxValue), (.)duration);
			}
			else if (sdlJoysticks[index] != null)
			{
				SDL.JoystickRumble(sdlJoysticks[index], (.)(leftMotor * uint16.MaxValue), (.)(rightMotor * uint16.MaxValue), (.)duration);
			}
		}

		public override void SetMouseCursor(Cursors cursor)
		{
			if (cursor == .Hidden)
			{
				SDL.ShowCursor(0);
				cursorHidden = true;
				return;
			}
			else if (cursorHidden)
			{
				SDL.ShowCursor(1);
				cursorHidden = false;
			}

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
			default: // Already handled
			}

			if (sdlCursors[index] == null)
				sdlCursors[index] = SDL.CreateSystemCursor((SDL.SDL_SystemCursor)index);

			SDL.SetCursor(sdlCursors[index]);
		}

		[Inline]
		public override void SetClipboardString(System.String value)
		{
			SDL.SetClipboardText(value);
		}

		[Inline]
		public override void GetClipboardString(System.String buffer)
		{
			if (SDL.HasClipboardText() == SDL.Bool.True)
				buffer.Append(SDL.GetClipboardText());
		}

		public override Point2 MousePosition
		{
			[Inline]
			get
			{
				SDL.GetWindowPosition(Core.Window.window, let winX, let winY);
				int32 x = 0, y = 0;
				SDL.GetGlobalMouseState(&x, &y);
				return Point2(x - winX, y - winY);
			}

			[Inline]
			set => SDL.WarpMouseInWindow(Core.Window.window, (int32)value.X, (int32)value.Y);
		}

		internal void ProcessEvent(SDL.Event e)
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
				let index = e.jdevice.which;

				if (index >= 0 && maxControllers < (uint)index && SDL.IsGameController(index) == SDL.Bool.False)
				{
				    let ptr = sdlJoysticks[index] = SDL.JoystickOpen(index);
				    let buttonCount = SDL.JoystickNumButtons(ptr);
				    let axisCount = SDL.JoystickNumAxes(ptr);

				    OnJoystickConnect((uint)index, (uint)buttonCount, (uint)axisCount, false);
				}
			case .JoyDeviceRemoved:
				let index = e.jdevice.which;

				if (index >= 0 && maxControllers < (uint)index && SDL.IsGameController(index) == SDL.Bool.False)
				{
				    OnJoystickDisconnect((uint)index);

				    let ptr = sdlJoysticks[index];
				    sdlJoysticks[index] = null;
				    SDL.JoystickClose(ptr);
				}
			case .JoyButtonDown:
				let index = e.jbutton.which;
				if (SDL.IsGameController(index) == SDL.Bool.False)
				    OnJoystickButtonDown((uint)index, e.jbutton.button);
			case .JoyButtonUp:
				let index = e.jbutton.which;
				if (SDL.IsGameController(index) == SDL.Bool.False)
				    OnJoystickButtonUp((uint)index, e.jbutton.button);
			case .JoyAxisMotion:
				let index = e.jaxis.which;
				if (SDL.IsGameController(index) == SDL.Bool.False)
				{
				    let value = Math.Max(-1f, Math.Min(1f, (int16)e.jaxis.axisValue / (float)Int16.MaxValue));
				    OnJoystickAxis((uint)index, e.jaxis.axis, value);
				}
				// Controller events
			case .ControllerDeviceadded:
				let index = e.cdevice.which;
				sdlGamepads[index] = SDL.GameControllerOpen(index);
				OnJoystickConnect((uint)index, 15, 6, true);
			case .ControllerDeviceremoved:
				let index = e.cdevice.which;
				OnJoystickDisconnect((uint)index);

				let ptr = sdlGamepads[index];
				sdlGamepads[index] = null;
				SDL.GameControllerClose(ptr);
			case .ControllerButtondown:
				let index = e.cbutton.which;
				let button = GamepadButtonToEnum(e.cbutton.button);

				OnGamepadButtonDown((uint)index, button);
			case .ControllerButtonup:
				let index = e.cbutton.which;
				let button = GamepadButtonToEnum(e.cbutton.button);

				OnGamepadButtonUp((uint)index, button);
			case .ControllerAxismotion:
				let index = e.caxis.which;
				let axis = GamepadAxisToEnum(e.caxis.axis);
				let value = Math.Max(-1f, Math.Min(1f, e.caxis.axisValue / (float)Int16.MaxValue));

				OnGamepadAxis((uint)index, axis, value);
				// Key events
			case .KeyDown, .KeyUp:
				if (e.key.isRepeat == 0)
				{
				    let keycode = e.key.keysym.sym;
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
		
		static Buttons GamepadButtonToEnum(uint8 button)
		{
			Buttons output;
		    switch (button)
		    {
		        case (uint8)SDL.SDL_GameControllerButton.A: output = .A;
		        case (uint8)SDL.SDL_GameControllerButton.B: output = .B;
		        case (uint8)SDL.SDL_GameControllerButton.X: output = .X;
		        case (uint8)SDL.SDL_GameControllerButton.Y: output = .Y;
		        case (uint8)SDL.SDL_GameControllerButton.Back: output = .Back;
		        case (uint8)SDL.SDL_GameControllerButton.Guide: output = .Select;
		        case (uint8)SDL.SDL_GameControllerButton.Start: output = .Start;
		        case (uint8)SDL.SDL_GameControllerButton.LeftStick: output = .LeftStick;
		        case (uint8)SDL.SDL_GameControllerButton.RightStick: output = .RightStick;
		        case (uint8)SDL.SDL_GameControllerButton.LeftShoulder: output = .LeftShoulder;
		        case (uint8)SDL.SDL_GameControllerButton.RightShoulder: output = .RightShoulder;
		        case (uint8)SDL.SDL_GameControllerButton.DpadUp: output = .Up;
		        case (uint8)SDL.SDL_GameControllerButton.DpadDown: output = .Down;
		        case (uint8)SDL.SDL_GameControllerButton.DpadLeft: output = .Left;
		        case (uint8)SDL.SDL_GameControllerButton.DpadRight: output = .Right;
		        default: output = .Unknown;
		    }
			return output;
		}

		static Axes GamepadAxisToEnum(uint8 axes)
		{
			Axes output;
		    switch (axes)
		    {
		        case (uint8)SDL.SDL_GameControllerAxis.LeftX: output = .LeftX;
		        case (uint8)SDL.SDL_GameControllerAxis.LeftY: output = .LeftY;
		        case (uint8)SDL.SDL_GameControllerAxis.RightX: output = .RightX;
		        case (uint8)SDL.SDL_GameControllerAxis.TriggerLeft: output = .LeftTrigger;
		        case (uint8)SDL.SDL_GameControllerAxis.TriggerRight: output = .RightTrigger;
		        default: output = .Unknown;
		    }
			return output;
		}

		static Keys KeycodeToEnum(SDL.Keycode keycode)
		{
			Keys output;
			switch (keycode)
			{
			case .Num0: output = .D0;
			case .Num1: output = .D1;
			case .Num2: output = .D2;
			case .Num3: output = .D3;
			case .Num4: output = .D4;
			case .Num5: output = .D5;
			case .Num6: output = .D6;
			case .Num7: output = .D7;
			case .Num8: output = .D8;
			case .Num9: output = .D9;

			case .A: output = .A;
			case .B: output = .B;
			case .C: output = .C;
			case .D: output = .D;
			case .E: output = .E;
			case .F: output = .F;
			case .G: output = .G;
			case .H: output = .H;
			case .I: output = .I;
			case .J: output = .J;
			case .K: output = .K;
			case .L: output = .L;
			case .M: output = .M;
			case .N: output = .N;
			case .O: output = .O;
			case .P: output = .P;
			case .Q: output = .Q;
			case .R: output = .R;
			case .S: output = .S;
			case .T: output = .T;
			case .U: output = .U;
			case .V: output = .V;
			case .W: output = .W;
			case .X: output = .X;
			case .Y: output = .Y;
			case .Z: output = .Z;

			case .LSHIFT: output = .LeftShift;
			case .LCTRL: output = .LeftControl;
			case .LALT: output = .LeftAlt;
			case .LGUI: output = .LeftSuper;
			case .RSHIFT: output = .RightShift;
			case .RCTRL: output = .RightControl;
			case .RALT: output = .RightAlt;
			case .RGUI: output = .RightSuper;

			case .SPACE: output = .Space;
			case .QUOTE: output = .Apostrophe;
			case .COMMA, .KP_COMMA: output = .Comma;
			case .MINUS: output = .Minus;
			case .PERIOD: output = .Period;
			case .SLASH: output = .Slash;

			case .Leftbracket: output = .LeftBracket;
			case .Backslash: output = .BackSlash;
			case .Rightbracket: output = .RightBracket;
			case .Backquote: output = .GraveAccent;
			case .ESCAPE: output = .Escape;
			case .RETURN, .RETURN2: output = .Enter;
			case .TAB: output = .Tab;
			case .BACKSPACE: output = .Backspace;
			case .INSERT: output = .Insert;
			case .DELETE: output = .Delete;
			case .RIGHT: output = .Right;
			case .LEFT: output = .Left;
			case .DOWN: output = .Down;
			case .UP: output = .Up;
			case .PAGEUP: output = .PageUp;
			case .PAGEDOWN: output = .PageDown;
			case .HOME: output = .Home;
			case .MENU: output = .Menu;
			case .END: output = .End;
			case .CAPSLOCK: output = .CapsLock;
			case .SCROLLLOCK: output = .ScrollLock;
			case .NUMLOCKCLEAR: output = .NumLock;
			case .PRINTSCREEN: output = .PrintScreen;
			case .PAUSE: output = .Pause;
			case .Semicolon: output = .Semicolon;
			case .Equals: output = .Equal;

			case .F1: output = .F1;
			case .F2: output = .F2;
			case .F3: output = .F3;
			case .F4: output = .F4;
			case .F5: output = .F5;
			case .F6: output = .F6;
			case .F7: output = .F7;
			case .F8: output = .F8;
			case .F9: output = .F9;
			case .F10: output = .F10;
			case .F11: output = .F11;
			case .F12: output = .F12;
			case .F13: output = .F13;
			case .F14: output = .F14;
			case .F15: output = .F15;
			case .F16: output = .F16;
			case .F17: output = .F17;
			case .F18: output = .F18;
			case .F19: output = .F19;
			case .F20: output = .F20;
			case .F21: output = .F21;
			case .F22: output = .F22;
			case .F23: output = .F23;
			case .F24: output = .F24;

			case .KP0: output = .KP_0;
			case .KP1: output = .KP_1;
			case .KP2: output = .KP_2;
			case .KP3: output = .KP_3;
			case .KP4: output = .KP_4;
			case .KP5: output = .KP_5;
			case .KP6: output = .KP_6;
			case .KP7: output = .KP_7;
			case .KP8: output = .KP_8;
			case .KP9: output = .KP_9;

			case .KPDECIMAL: output = .KP_Decimal;
			case .KP_DIVIDE: output = .KP_Divide;
			case .KPMULTIPLY: output = .KP_Multiply;
			case .KPMINUS: output = .KP_Subtract;
			case .KPPLUS: output = .KP_Add;
			case .KPENTER: output = .KP_Enter;
			case .KPEQUALS: output = .KP_Equal;

			case .UNKNOWN: output = .Unknown;
			default: output = .Unknown;
			}
			return output;
		}
	}
}
