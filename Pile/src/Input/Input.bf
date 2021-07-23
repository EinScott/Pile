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
		public static readonly Keyboard Keyboard => state.keyboard;
		[Inline]
		public static readonly Mouse Mouse => state.mouse;
		[Inline]
		public static readonly ref Controller GetController(Controllers index) => ref state.GetController(index);

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
			DeleteContainerAndItems!(virtualButtons);
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
			Debug.Assert(index >= 0 && index < (.)MaxControllers);
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

		static void OnKeyDown(Keys key)
		{
		    int id = (int)key;
		    if (id < Pile.Keyboard.MaxKeys)
			{
			    nextState.keyboard.down[[Unchecked]id] = true;
			    nextState.keyboard.pressed[[Unchecked]id] = true;
			    nextState.keyboard.timestamp[[Unchecked]id] = Time.Duration.Ticks;
			}
		}

		static void OnKeyUp(Keys key)
		{
		    int id = (int)key;
		    if (id < Pile.Keyboard.MaxKeys)
		    {
			    nextState.keyboard.down[[Unchecked]id] = false;
			    nextState.keyboard.released[[Unchecked]id] = true;
			}
		}

		static void OnMouseDown(MouseButtons button)
		{
		    nextState.mouse.down[button.Underlying] = true;
		    nextState.mouse.pressed[button.Underlying] = true;
		    nextState.mouse.timestamp[button.Underlying] = Time.Duration.Ticks;
		}

		static void OnMouseUp(MouseButtons button)
		{
		    nextState.mouse.down[button.Underlying] = false;
		    nextState.mouse.released[button.Underlying] = true;
		}

		static void OnMouseWheel(float offsetX, float offsetY)
		{
		    nextState.mouse.wheelValue = Vector2(offsetX, offsetY);
		}

		static void OnJoystickConnect(uint index, uint buttonCount, uint axisCount, bool isGamepad)
		{
		    if (index < MaxControllers)
		        nextState.controllers[[Unchecked](int)index].Connect(buttonCount, axisCount, isGamepad);
		}

		static void OnJoystickDisconnect(uint index)
		{
		    if (index < MaxControllers)
		        nextState.controllers[[Unchecked](int)index].Disconnect();
		}

		static void OnJoystickButtonDown(uint index, uint button)
		{
		    if (index < MaxControllers && button < Controller.MaxButtons)
		    {
		        nextState.controllers[[Unchecked](int)index].down[[Unchecked](int)button] = true;
		        nextState.controllers[[Unchecked](int)index].pressed[[Unchecked](int)button] = true;
		        nextState.controllers[[Unchecked](int)index].timestamp[[Unchecked](int)button] = Time.Duration.Ticks;
		    }
		}

		static void OnJoystickButtonUp(uint index, uint button)
		{
		    if (index < MaxControllers && button < Controller.MaxButtons)
		    {
		        nextState.controllers[[Unchecked](int)index].down[[Unchecked](int)button] = false;
		        nextState.controllers[[Unchecked](int)index].released[[Unchecked](int)button] = true;
		    }
		}

		static void OnGamepadButtonDown(uint index, Buttons button)
		{
		    if (index < MaxControllers)
		    {
		        nextState.controllers[[Unchecked](int)index].down[button.Underlying] = true;
		        nextState.controllers[[Unchecked](int)index].pressed[button.Underlying] = true;
		        nextState.controllers[[Unchecked](int)index].timestamp[button.Underlying] = Time.Duration.Ticks;
		    }
		}

		static void OnGamepadButtonUp(uint index, Buttons button)
		{
		    if (index < MaxControllers)
		    {
		        nextState.controllers[[Unchecked](int)index].down[button.Underlying] = false;
		        nextState.controllers[[Unchecked](int)index].released[button.Underlying] = true;
		    }
		}

		static bool IsJoystickButtonDown(uint index, uint button)
		{
		    return (index < MaxControllers && button < Controller.MaxButtons && nextState.controllers[[Unchecked](int)index].down[[Unchecked](int)button]);
		}

		static bool IsGamepadButtonDown(uint index, Buttons button)
		{
		    return (index < MaxControllers && nextState.controllers[[Unchecked](int)index].down[button.Underlying]);
		}

		static void OnJoystickAxis(uint index, uint axis, float value)
		{
		    if (index < MaxControllers && axis < Controller.MaxAxis)
		    {
		        nextState.controllers[[Unchecked](int)index].axis[[Unchecked](int)axis] = value;
		        nextState.controllers[[Unchecked](int)index].axisTimestamp[[Unchecked](int)axis] = Time.Duration.Ticks;
		    }
		}

		static float GetJoystickAxis(uint index, uint axis)
		{
		    if (index < MaxControllers && axis < Controller.MaxAxis)
		        return nextState.controllers[[Unchecked](int)index].axis[[Unchecked](int)axis];
		    return 0;
		}

		static void OnGamepadAxis(uint index, Axes axis, float value)
		{
		    if (index < MaxControllers)
		    {
		        nextState.controllers[[Unchecked](int)index].axis[axis.Underlying] = value;
		        nextState.controllers[[Unchecked](int)index].axisTimestamp[axis.Underlying] = Time.Duration.Ticks;
		    }
		}

		static float GetGamepadAxis(uint index, Axes axis)
		{
		    if (index < MaxControllers)
		        return nextState.controllers[[Unchecked](int)index].axis[axis.Underlying];
		    return 0;
		}
	}
}
