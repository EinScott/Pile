using System.Collections;
using System;

using internal Pile;

namespace Pile
{
	public abstract class Input
	{
		public readonly InputState state;
		public readonly InputState lastState;
		public readonly InputState nextState;
		internal readonly uint maxControllers;

		public Keyboard Keyboard => state.keyboard;
		public Mouse Mouse => state.mouse;
		public Controller GetController(int index) => state.GetController(index);

		public float repeatDelay = 0.4f;
		public float repeatInterval = 0.03f;

		internal List<VirtualButton> virtualButtons = new List<VirtualButton>();

		internal this(int maxControllers = 8)
		{
			state = new InputState(this, maxControllers);
			lastState = new InputState(this, maxControllers);
			nextState = new InputState(this, maxControllers);

			if (maxControllers < 0) this.maxControllers = 0;
			else this.maxControllers = (uint)maxControllers;
		}

		public ~this()
		{
			delete state;
			delete lastState;
			delete nextState;

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

		public abstract void SetMouseCursor(Cursors cursor);

		public abstract void SetClipboardString(String value);
		public abstract void GetClipboardString(String buffer);

		public abstract Point2 MousePosition { get; set; }

		public Event<Action<char16>> OnTextTyped;

		protected void OnText(char16 value)
		{
		    OnTextTyped(value);
		    nextState.keyboard.Text.Append(value);
		}

		protected void OnKeyDown(Keys key)
		{
		    int id = (int)key;
		    if (id < Pile.Keyboard.MaxKeys)
			{
			    nextState.keyboard.down[id] = true;
			    nextState.keyboard.pressed[id] = true;
			    nextState.keyboard.timestamp[id] = Time.Duration.Ticks;
			}
		}

		protected void OnKeyUp(Keys key)
		{
		    int id = (int)key;
		    if (id < Pile.Keyboard.MaxKeys)
		    {
			    nextState.keyboard.down[id] = false;
			    nextState.keyboard.released[id] = true;
			}
		}

		protected void OnMouseDown(MouseButtons button)
		{
		    nextState.mouse.down[(int)button] = true;
		    nextState.mouse.pressed[(int)button] = true;
		    nextState.mouse.timestamp[(int)button] = Time.Duration.Ticks;
		}

		protected void OnMouseUp(MouseButtons button)
		{
		    nextState.mouse.down[(int)button] = false;
		    nextState.mouse.released[(int)button] = true;
		}

		protected void OnMouseWheel(float offsetX, float offsetY)
		{
		    nextState.mouse.wheelValue = Vector2(offsetX, offsetY);
		}

		protected void OnJoystickConnect(uint index, uint buttonCount, uint axisCount, bool isGamepad)
		{
		    if (index < maxControllers)
		        nextState.controllers[(int)index].Connect(buttonCount, axisCount, isGamepad);
		}

		protected void OnJoystickDisconnect(uint index)
		{
		    if (index < maxControllers)
		        nextState.controllers[(int)index].Disconnect();
		}

		protected void OnJoystickButtonDown(uint index, uint button)
		{
		    if (index < maxControllers && button < Controller.MaxButtons)
		    {
		        nextState.controllers[(int)index].down[(int)button] = true;
		        nextState.controllers[(int)index].pressed[(int)button] = true;
		        nextState.controllers[(int)index].timestamp[(int)button] = Time.Duration.Ticks;
		    }
		}

		protected void OnJoystickButtonUp(uint index, uint button)
		{
		    if (index < maxControllers && button < Controller.MaxButtons)
		    {
		        nextState.controllers[(int)index].down[(int)button] = false;
		        nextState.controllers[(int)index].released[(int)button] = true;
		    }
		}

		protected void OnGamepadButtonDown(uint index, Buttons button)
		{
		    if (index < maxControllers)
		    {
		        nextState.controllers[(int)index].down[(int)button] = true;
		        nextState.controllers[(int)index].pressed[(int)button] = true;
		        nextState.controllers[(int)index].timestamp[(int)button] = Time.Duration.Ticks;
		    }
		}

		protected void OnGamepadButtonUp(uint index, Buttons button)
		{
		    if (index < maxControllers)
		    {
		        nextState.controllers[(int)index].down[(int)button] = false;
		        nextState.controllers[(int)index].released[(int)button] = true;
		    }
		}

		protected bool IsJoystickButtonDown(uint index, uint button)
		{
		    return (index < maxControllers && button < Controller.MaxButtons && nextState.controllers[(int)index].down[(int)button]);
		}

		protected bool IsGamepadButtonDown(uint index, Buttons button)
		{
		    return (index < maxControllers && nextState.controllers[(int)index].down[(int)button]);
		}

		protected void OnJoystickAxis(uint index, uint axis, float value)
		{
		    if (index < maxControllers && axis < Controller.MaxAxis)
		    {
		        nextState.controllers[(int)index].axis[(int)axis] = value;
		        nextState.controllers[(int)index].axisTimestamp[(int)axis] = Time.Duration.Ticks;
		    }
		}

		protected float GetJoystickAxis(uint index, uint axis)
		{
		    if (index < maxControllers && axis < Controller.MaxAxis)
		        return nextState.controllers[(int)index].axis[(int)axis];
		    return 0;
		}

		protected void OnGamepadAxis(uint index, Axes axis, float value)
		{
		    if (index < maxControllers)
		    {
		        nextState.controllers[(int)index].axis[(int)axis] = value;
		        nextState.controllers[(int)index].axisTimestamp[(int)axis] = Time.Duration.Ticks;
		    }
		}

		protected float GetGamepadAxis(uint index, Axes axis)
		{
		    if (index < maxControllers)
		        return nextState.controllers[(int)index].axis[(int)axis];
		    return 0;
		}
	}
}
