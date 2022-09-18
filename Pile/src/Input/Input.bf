using System.Collections;
using System.Diagnostics;
using System;
using System.Text;

using internal Pile;

namespace Pile
{
	static class Input
	{
		public const uint MaxControllers = Controllers.Count();

		internal static InputState state = InputState();
		internal static InputState lastState = InputState();
		internal static InputState nextState = InputState();

		[Inline]
		public static ref Keyboard Keyboard => ref state.keyboard;
		[Inline]
		public static ref Mouse Mouse => ref state.mouse;
		[Inline]
		public static ref Controller GetController(Controllers index) => ref state.GetController(index);

		public static float repeatDelay = 0.4f;
		public static float repeatInterval = 0.03f;

		/// Default: true. If false, key presses are always reported on the QWERTY layout based on scan codes.
		/// Otherwise the key code reported by the OS will be used, but these may not be recognized by name.
		public static bool UseLocalKeyLayout = true;

		internal static List<VirtualButton> virtualButtons = new List<VirtualButton>();
		internal static bool deleting;

		protected internal static extern void Initialize();
		protected internal static extern void Destroy();

		static ~this()
		{
			state.Dispose();
			lastState.Dispose();
			nextState.Dispose();

			deleting = true;
			delete virtualButtons;
		}

		internal static void Step()
		{
			lastState.Copy(state);
			state.Copy(nextState);
			nextState.Step();

			for (int i = 0; i < virtualButtons.Count; i++)
				virtualButtons[i].Update();
		}

		[Inline]
		/// left- and rightMotor should only be floats from 0.0 to 1.0, duration is in MS
		public static void SetControllerRumble(Controllers index, float leftMotor, float rightMotor, uint duration)
		{
			Debug.Assert((uint)index < MaxControllers);
			Debug.Assert(leftMotor >= 0 && leftMotor <= 1);
			Debug.Assert(rightMotor >= 0 && rightMotor <= 1);

			SetControllerRumbleInternal(index.Underlying, leftMotor, rightMotor, duration);
		}
		public static extern void SetControllerRumbleInternal(int index, float leftMotor, float rightMotor, uint duration);

		public static extern void SetMouseCursor(Cursors cursor);

		public static extern void SetClipboardString(String value);
		public static extern void GetClipboardString(String buffer);

		public static extern Point2 MousePosition { get; set; }

		public static Event<delegate void(char32)> OnTextTyped;

		/// Expects a UTF8 string
		static void OnText(StringView text)
		{
			var index = 0;
			while (index < text.Length)
			{
				let res = UTF8.Decode(&text[index], text.Length - index);
				Debug.Assert(res.length != 0);

				if (OnTextTyped.HasListeners)
					OnTextTyped(res.c);
				
				nextState.keyboard.Text.Append(StringView(&text[index], res.length));
				index += res.length;
			}
		}

		[Inline]
		static void OnKeyDown(Keys key)
		{
		    nextState.keyboard.state[(int)key] |= .Pressed|.Down;
			nextState.keyboard.timestamp[[Unchecked](int)key] = Time.Duration.Ticks;
		}

		[Inline]
		static void OnKeyUp(Keys key)
		{
		    nextState.keyboard.state[(int)key] = (nextState.keyboard.state[[Unchecked](int)key] & ~.Down) | .Released;
		}

		[Inline]
		static void OnMouseDown(MouseButtons button)
		{
		    nextState.mouse.state[(int)button] |= .Pressed|.Down;
		    nextState.mouse.timestamp[[Unchecked](int)button] = Time.Duration.Ticks;
		}

		[Inline]
		static void OnMouseUp(MouseButtons button)
		{
			nextState.mouse.state[(int)button] = (nextState.mouse.state[[Unchecked](int)button] & ~.Down) | .Released;
		}

		[Inline]
		static void OnMouseWheel(float offsetX, float offsetY)
		{
		    nextState.mouse.wheelValue = Vector2(offsetX, offsetY);
		}

		[Inline]
		static void OnJoystickConnect(uint index, uint buttonCount, uint axisCount, bool isGamepad)
		{
		    nextState.controllers[[Unchecked]index].Connect(buttonCount, axisCount, isGamepad);
		}

		[Inline]
		static void OnJoystickDisconnect(uint index)
		{
		    nextState.controllers[[Unchecked]index].Disconnect();
		}

		[Inline]
		static void OnJoystickButtonDown(uint index, uint button)
		{
			if (button < Controller.MaxButtons)
			{
				nextState.controllers[[Unchecked](int)index].state[[Unchecked]button] |= .Pressed|.Down;
				nextState.controllers[[Unchecked](int)index].timestamp[[Unchecked]button] = Time.Duration.Ticks;
			}
		}

		[Inline]
		static void OnJoystickButtonUp(uint index, uint button)
		{
			if (button < Controller.MaxButtons)
		    	nextState.controllers[[Unchecked](int)index].state[[Unchecked]button] = (nextState.controllers[[Unchecked](int)index].state[[Unchecked]button] & ~.Down) | .Released;
		}

		[Inline]
		static void OnGamepadButtonDown(uint index, Buttons button)
		{
		    nextState.controllers[[Unchecked](int)index].state[[Unchecked](int)button] |= .Pressed|.Down;
			nextState.controllers[[Unchecked](int)index].timestamp[[Unchecked](int)button] = Time.Duration.Ticks;
		}

		static void OnGamepadButtonUp(uint index, Buttons button)
		{
		    nextState.controllers[[Unchecked](int)index].state[[Unchecked](int)button] = (nextState.controllers[[Unchecked](int)index].state[[Unchecked](int)button] & ~.Down) | .Released;
		}

		static void OnJoystickAxis(uint index, uint axis, float value)
		{
		    if (axis < Controller.MaxAxis)
		    {
		        nextState.controllers[[Unchecked]index].axis[[Unchecked]axis] = value;
		        nextState.controllers[[Unchecked]index].axisTimestamp[[Unchecked]axis] = Time.Duration.Ticks;
		    }
		}

		static void OnGamepadAxis(uint index, Axes axis, float value)
		{
			nextState.controllers[[Unchecked]index].axis[[Unchecked](int)axis] = value;
			nextState.controllers[[Unchecked]index].axisTimestamp[[Unchecked](int)axis] = Time.Duration.Ticks;
		}
	}
}
