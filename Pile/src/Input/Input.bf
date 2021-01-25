using System.Collections;
using System.Diagnostics;
using System;

using internal Pile;

namespace Pile
{
	public class Input
	{
		internal InputState state;
		internal InputState lastState;
		internal InputState nextState;
		internal readonly uint maxControllers;

		public readonly Keyboard Keyboard => state.keyboard;
		public readonly Mouse Mouse => state.mouse;
		public readonly ref Controller GetController(int index) => ref state.GetController(index);

		public float repeatDelay = 0.4f;
		public float repeatInterval = 0.03f;

		internal List<VirtualButton> virtualButtons = new List<VirtualButton>();

		internal this(int maxControllers = 8)
		{
			state = InputState(this, maxControllers);
			lastState = InputState(this, maxControllers);
			nextState = InputState(this, maxControllers);

			if (maxControllers < 0) this.maxControllers = 0;
			else this.maxControllers = (uint)maxControllers;

			Initialize();
		}

		protected internal extern void Initialize();

		internal ~this()
		{
			state.Dispose();
			lastState.Dispose();
			nextState.Dispose();

			for (int i = 0; i < virtualButtons.Count; i++)
				virtualButtons[i].deletingList = true;
			DeleteContainerAndItems!(virtualButtons);
		}

		internal void Step()
		{
			lastState.Copy(state);
			state.Copy(nextState);
			nextState.Step();

			for (int i = 0; i < virtualButtons.Count; i++)
				virtualButtons[i].Update();
		}

		[Inline]
		/// left- and rightMotor should only be floats from 0.0 to 1.0, duration is in MS
		public void SetControllerRumble(int index, float leftMotor, float rightMotor, uint duration)
		{
			Debug.Assert(index >= 0 && index < (.)maxControllers);
			Debug.Assert(leftMotor >= 0 && leftMotor <= 1);
			Debug.Assert(rightMotor >= 0 && rightMotor <= 1);

			SetControllerRumbleInternal(index, leftMotor, rightMotor, duration);
		}
		public extern void SetControllerRumbleInternal(int index, float leftMotor, float rightMotor, uint duration);

		public extern void SetMouseCursor(Cursors cursor);

		public extern void SetClipboardString(String value);
		public extern void GetClipboardString(String buffer);

		public extern Point2 MousePosition { get; set; }

		public Event<delegate void(char16)> OnTextTyped;

		private void OnText(char16 value)
		{
		    OnTextTyped(value);
		    nextState.keyboard.Text.Append(value);
		}

		private void OnKeyDown(Keys key)
		{
		    int id = (int)key;
		    if (id < Pile.Keyboard.MaxKeys)
			{
			    nextState.keyboard.down[id] = true;
			    nextState.keyboard.pressed[id] = true;
			    nextState.keyboard.timestamp[id] = Time.Duration.Ticks;
			}
		}

		private void OnKeyUp(Keys key)
		{
		    int id = (int)key;
		    if (id < Pile.Keyboard.MaxKeys)
		    {
			    nextState.keyboard.down[id] = false;
			    nextState.keyboard.released[id] = true;
			}
		}

		private void OnMouseDown(MouseButtons button)
		{
		    nextState.mouse.down[(int)button] = true;
		    nextState.mouse.pressed[(int)button] = true;
		    nextState.mouse.timestamp[(int)button] = Time.Duration.Ticks;
		}

		private void OnMouseUp(MouseButtons button)
		{
		    nextState.mouse.down[(int)button] = false;
		    nextState.mouse.released[(int)button] = true;
		}

		private void OnMouseWheel(float offsetX, float offsetY)
		{
		    nextState.mouse.wheelValue = Vector2(offsetX, offsetY);
		}

		private void OnJoystickConnect(uint index, uint buttonCount, uint axisCount, bool isGamepad)
		{
		    if (index < maxControllers)
		        nextState.controllers[(int)index].Connect(buttonCount, axisCount, isGamepad);
		}

		private void OnJoystickDisconnect(uint index)
		{
		    if (index < maxControllers)
		        nextState.controllers[(int)index].Disconnect();
		}

		private void OnJoystickButtonDown(uint index, uint button)
		{
		    if (index < maxControllers && button < Controller.MaxButtons)
		    {
		        nextState.controllers[(int)index].down[(int)button] = true;
		        nextState.controllers[(int)index].pressed[(int)button] = true;
		        nextState.controllers[(int)index].timestamp[(int)button] = Time.Duration.Ticks;
		    }
		}

		private void OnJoystickButtonUp(uint index, uint button)
		{
		    if (index < maxControllers && button < Controller.MaxButtons)
		    {
		        nextState.controllers[(int)index].down[(int)button] = false;
		        nextState.controllers[(int)index].released[(int)button] = true;
		    }
		}

		private void OnGamepadButtonDown(uint index, Buttons button)
		{
		    if (index < maxControllers)
		    {
		        nextState.controllers[(int)index].down[(int)button] = true;
		        nextState.controllers[(int)index].pressed[(int)button] = true;
		        nextState.controllers[(int)index].timestamp[(int)button] = Time.Duration.Ticks;
		    }
		}

		private void OnGamepadButtonUp(uint index, Buttons button)
		{
		    if (index < maxControllers)
		    {
		        nextState.controllers[(int)index].down[(int)button] = false;
		        nextState.controllers[(int)index].released[(int)button] = true;
		    }
		}

		private bool IsJoystickButtonDown(uint index, uint button)
		{
		    return (index < maxControllers && button < Controller.MaxButtons && nextState.controllers[(int)index].down[(int)button]);
		}

		private bool IsGamepadButtonDown(uint index, Buttons button)
		{
		    return (index < maxControllers && nextState.controllers[(int)index].down[(int)button]);
		}

		private void OnJoystickAxis(uint index, uint axis, float value)
		{
		    if (index < maxControllers && axis < Controller.MaxAxis)
		    {
		        nextState.controllers[(int)index].axis[(int)axis] = value;
		        nextState.controllers[(int)index].axisTimestamp[(int)axis] = Time.Duration.Ticks;
		    }
		}

		private float GetJoystickAxis(uint index, uint axis)
		{
		    if (index < maxControllers && axis < Controller.MaxAxis)
		        return nextState.controllers[(int)index].axis[(int)axis];
		    return 0;
		}

		private void OnGamepadAxis(uint index, Axes axis, float value)
		{
		    if (index < maxControllers)
		    {
		        nextState.controllers[(int)index].axis[(int)axis] = value;
		        nextState.controllers[(int)index].axisTimestamp[(int)axis] = Time.Duration.Ticks;
		    }
		}

		private float GetGamepadAxis(uint index, Axes axis)
		{
		    if (index < maxControllers)
		        return nextState.controllers[(int)index].axis[(int)axis];
		    return 0;
		}
	}
}
