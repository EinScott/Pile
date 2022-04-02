using SDL2;
using System;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	extension Input
	{
		static bool cursorHidden;
		static SDL.SDL_Cursor*[(int)SDL.SDL_SystemCursor.SDL_SYSTEM_CURSOR_SIZEALL] sdlCursors = .();
		static SDL.SDL_Joystick*[MaxControllers] sdlJoysticks = .();
		static SDL.SDL_GameController*[MaxControllers] sdlGamepads = .();

		protected internal static override void Initialize()
		{
			
		}

		protected internal override static void Destroy()
		{
			for (int i = 0; i < sdlCursors.Count; i++)
			{
				if (sdlCursors[i] != null)
					SDL.FreeCursor(sdlCursors[i]);
			}
		}

		public static override void SetControllerRumbleInternal(int index, float leftMotor, float rightMotor, uint duration)
		{
			if (sdlGamepads[index] != null)
			{
				let gameController = sdlGamepads[index];
				if (!SDL.GameControllerHasRumble(gameController))
					return;
				SDL.GameControllerRumble(gameController, (.)(leftMotor * uint16.MaxValue), (.)(rightMotor * uint16.MaxValue), (.)duration);
			}
			else if (sdlJoysticks[index] != null)
			{
				let joystick = sdlJoysticks[index];
				if (!SDL.JoystickHasRumble(joystick))
					return;
				SDL.JoystickRumble(joystick, (.)(leftMotor * uint16.MaxValue), (.)(rightMotor * uint16.MaxValue), (.)duration);
			}
		}

		public static override void SetMouseCursor(Cursors cursor)
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
		public static override void SetClipboardString(System.String value)
		{
			SDL.SetClipboardText(value);
		}

		[Inline]
		public static override void GetClipboardString(System.String buffer)
		{
			if (SDL.HasClipboardText() == SDL.Bool.True)
				buffer.Append(SDL.GetClipboardText());
		}

		public static override Point2 MousePosition
		{
			[Inline]
			get
			{
				SDL.GetWindowPosition(System.Window.window, let winX, let winY);
				int32 x = 0, y = 0;
				SDL.GetGlobalMouseState(&x, &y);
				return Point2(x - winX, y - winY);
			}

			[Inline]
			set => SDL.WarpMouseInWindow(System.Window.window, (int32)value.X, (int32)value.Y);
		}

		internal static void ProcessEvent(SDL.Event e)
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

				if ((uint)index < MaxControllers && SDL.IsGameController(index) == .False)
				{
					Debug.Assert(sdlJoysticks[index] == null);
				    let ptr = sdlJoysticks[index] = SDL.JoystickOpen(index);

					Debug.Assert(SDL.IsGameController(index) == .False);

				    let buttonCount = SDL.JoystickNumButtons(ptr);
				    let axisCount = SDL.JoystickNumAxes(ptr);

				    OnJoystickConnect((uint)index, (uint)buttonCount, (uint)axisCount, false);
				}
			case .JoyDeviceRemoved:
				let index = JoystickIdToIndex(e.jdevice.which);

				if (index >= 0)
				{
				    OnJoystickDisconnect((uint)index);

				    SDL.JoystickClose(sdlJoysticks[index]);
				    sdlJoysticks[index] = null;
				}
			case .JoyButtonDown:
				let index = JoystickIdToIndex(e.jbutton.which);
				if (index >= 0)
				    OnJoystickButtonDown((uint)index, e.jbutton.button);
			case .JoyButtonUp:
				let index = JoystickIdToIndex(e.jdevice.which);
				if (index >= 0)
				    OnJoystickButtonUp((uint)index, e.jbutton.button);
			case .JoyAxisMotion:
				let index = JoystickIdToIndex(e.jdevice.which);
				if (index >= 0)
				{
				    let value = Math.Clamp(e.jaxis.axisValue / (float)int16.MaxValue, -1f, 1f);
				    OnJoystickAxis((uint)index, e.jaxis.axis, value);
				}
				// Controller events
			case .ControllerDeviceadded:
				let index = e.cdevice.which;
				Debug.Assert(sdlGamepads[index] == null);
				if (sdlJoysticks[index] != null)
				{
					// No idea... sometimes a controller is not a controller at one time, but then still registers as one later anyway!
					SDL.JoystickClose(sdlJoysticks[index]);
					sdlJoysticks[index] = null;
				}

				sdlGamepads[index] = SDL.GameControllerOpen(index);
				OnJoystickConnect((uint)index, 15, 6, true);
			case .ControllerDeviceremoved:
				let index = GamepadIdToIndex(e.cdevice.which);
				if (index >= 0)
				{
					OnJoystickDisconnect((uint)index);

					SDL.GameControllerClose(sdlGamepads[index]);
					sdlGamepads[index] = null;
				}
			case .ControllerButtondown:
				let index = GamepadIdToIndex(e.cdevice.which);
				if (index >= 0)
				{
					let button = GamepadButtonToEnum(e.cbutton.button);
					OnGamepadButtonDown((uint)index, button);
				}
			case .ControllerButtonup:
				let index = e.cbutton.which;
				let button = GamepadButtonToEnum(e.cbutton.button);

				OnGamepadButtonUp((uint)index, button);
			case .ControllerAxismotion:
				let index = GamepadIdToIndex(e.cdevice.which);
				if (index >= 0)
				{
					let axis = GamepadAxisToEnum(e.caxis.axis);
					let value = Math.Clamp(e.caxis.axisValue / (float)int16.MaxValue, -1f, 1f);

					OnGamepadAxis((uint)index, axis, value);
				}
				// Key events
			case .KeyDown, .KeyUp:
				if (e.key.isRepeat == 0)
				{
					// Depending on the configuration, the keys reported do not match the
					// keyboard layout this to ensure controls are hopefully consistent
					// Actual text input should use OnTextTyped or keyboard.Text!
					Keys key = UseLocalKeyLayout ? KeycodeToEnum(e.key.keysym.sym) : ScancodeToEnum(e.key.keysym.scancode);

				    if (e.type == SDL.EventType.KeyDown)
				        OnKeyDown(key);
				    else
				        OnKeyUp(key);
				}
				// Text input events
			case .TextInput:
				int len = 0;
				while (e.text.text[len] != 0)
				    len++;

				var e;
				OnText(StringView((char8*)&e.text.text[0], len));
			default:
			}
		}

		static int32 JoystickIdToIndex(int32 id)
		{
			for (int32 i < sdlJoysticks.Count)
			{
				let j = sdlJoysticks[i];
				if (j != null && SDL.JoystickInstanceID(j) == id)
					return i;
			}
			return -1;
		}

		static int32 GamepadIdToIndex(int32 id)
		{
			for (int32 i < sdlGamepads.Count)
			{
				let g = sdlGamepads[i];
				if (g != null && SDL.JoystickInstanceID(SDL.GameControllerGetJoystick(g)) == id)
					return i;
			}
			return -1;
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
			case (uint8)SDL.SDL_GameControllerAxis.RightY: output = .RightY;
		    case (uint8)SDL.SDL_GameControllerAxis.TriggerLeft: output = .LeftTrigger;
		    case (uint8)SDL.SDL_GameControllerAxis.TriggerRight: output = .RightTrigger;
		    default: output = .Unknown;
		    }
			return output;
		}

		
		static Keys ScancodeToEnum(SDL.Scancode scancode)
		{
			Keys output;
			switch (scancode)
			{
			case .Key0: output = .D0;
			case .Key1: output = .D1;
			case .Key2: output = .D2;
			case .Key3: output = .D3;
			case .Key4: output = .D4;
			case .Key5: output = .D5;
			case .Key6: output = .D6;
			case .Key7: output = .D7;
			case .Key8: output = .D8;
			case .Key9: output = .D9;

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

			case .LShift: output = .LeftShift;
			case .LCtrl: output = .LeftControl;
			case .LAlt: output = .LeftAlt;
			case .LGui: output = .LeftSuper;
			case .RShift: output = .RightShift;
			case .RCtrl: output = .RightControl;
			case .RAlt: output = .RightAlt;
			case .RGui: output = .RightSuper;

			case .Space: output = .Space;
			case .Apostrophe: output = .Apostrophe;
			case .Comma, .KpComma: output = .Comma;
			case .Minus: output = .Minus;
			case .Period, .Kpperiod: output = .Period;
			case .Slash: output = .Slash;

			case .LeftBracket: output = .LeftBracket;
			case .BackSlash, .NonUSBackslash: output = .BackSlash;
			case .RightBracket: output = .RightBracket;
			case .Grave: output = .GraveAccent;
			case .Escape: output = .Escape;
			case .Return, .Return2: output = .Enter;
			case .Tab: output = .Tab;
			case .BackSpace: output = .Backspace;
			case .Insert: output = .Insert;
			case .Delete: output = .Delete;
			case .Right: output = .Right;
			case .Left: output = .Left;
			case .Down: output = .Down;
			case .Up: output = .Up;
			case .Pageup: output = .PageUp;
			case .PageDown: output = .PageDown;
			case .Home: output = .Home;
			case .Menu: output = .Menu;
			case .End: output = .End;
			case .CapsLock: output = .CapsLock;
			case .ScrollLock: output = .ScrollLock;
			case .NumLockClear: output = .NumLock;
			case .PrintScreen: output = .PrintScreen;
			case .Pause: output = .Pause;
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

			case .Kp0: output = .KP_0;
			case .Kp1: output = .KP_1;
			case .Kp2: output = .KP_2;
			case .Kp3: output = .KP_3;
			case .Kp4: output = .KP_4;
			case .Kp5: output = .KP_5;
			case .Kp6: output = .KP_6;
			case .Kp7: output = .KP_7;
			case .Kp8: output = .KP_8;
			case .Kp9: output = .KP_9;

			case .KpDecimal: output = .KP_Decimal;
			case .KpDivide: output = .KP_Divide;
			case .KpMultiply: output = .KP_Multiply;
			case .KpMinus: output = .KP_Subtract;
			case .KpPlus: output = .KP_Add;
			case .KpEnter: output = .KP_Enter;
			case .KpEquals: output = .KP_Equal;

			case .UNKNOWN: output = .Unknown;
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
			case .PERIOD, .KPPERIOD: output = .Period;
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
