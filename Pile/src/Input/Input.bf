using System.Collections;
using System;

namespace Pile
{
	public abstract class Input
	{
		public readonly InputState state;
		public readonly InputState lastState;
		public readonly InputState nextState;
		protected readonly uint maxControllers;

		public Keyboard Keyboard => state.keyboard;
		public Mouse Mouse => state.mouse;
		public Controller GetController(int index) => state.GetController(index);

		public float repeatDelay = 0.4f;
		public float repeatInterval = 0.03f;

		protected List<VirtualButton> virtualButtons = new List<VirtualButton>();

		public this(int maxControllers = 8)
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
				virtualButtons[i].[Friend]deletingList = true;
			DeleteContainerAndItems!(virtualButtons);
		}

		void Step()
		{
			lastState.[Friend]Copy(state);
			state.[Friend]Copy(nextState);
			nextState.[Friend]Step();

			for (int i = 0; i < virtualButtons.Count; i++)
				virtualButtons[i].[Friend]Update();
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
			    nextState.keyboard.[Friend]down[id] = true;
			    nextState.keyboard.[Friend]pressed[id] = true;
			    nextState.keyboard.[Friend]timestamp[id] = Time.Duration.Ticks;
			}
		}

		protected void OnKeyUp(Keys key)
		{
		    int id = (int)key;
		    if (id < Pile.Keyboard.MaxKeys)
		    {
			    nextState.keyboard.[Friend]down[id] = false;
			    nextState.keyboard.[Friend]released[id] = true;
			}
		}

		protected void OnMouseDown(MouseButtons button)
		{
		    nextState.mouse.[Friend]down[(int)button] = true;
		    nextState.mouse.[Friend]pressed[(int)button] = true;
		    nextState.mouse.[Friend]timestamp[(int)button] = Time.Duration.Ticks;
		}

		protected void OnMouseUp(MouseButtons button)
		{
		    nextState.mouse.[Friend]down[(int)button] = false;
		    nextState.mouse.[Friend]released[(int)button] = true;
		}

		protected void OnMouseWheel(float offsetX, float offsetY)
		{
		    nextState.mouse.[Friend]wheelValue = Vector2(offsetX, offsetY);
		}

		protected void OnJoystickConnect(uint index, uint buttonCount, uint axisCount, bool isGamepad)
		{
		    if (index < maxControllers)
		        nextState.[Friend]controllers[(int)index].[Friend]Connect(buttonCount, axisCount, isGamepad);
		}

		protected void OnJoystickDisconnect(uint index)
		{
		    if (index < maxControllers)
		        nextState.[Friend]controllers[(int)index].[Friend]Disconnect();
		}

		protected void OnJoystickButtonDown(uint index, uint button)
		{
		    if (index < maxControllers && button < Controller.MaxButtons)
		    {
		        nextState.[Friend]controllers[(int)index].[Friend]down[(int)button] = true;
		        nextState.[Friend]controllers[(int)index].[Friend]pressed[(int)button] = true;
		        nextState.[Friend]controllers[(int)index].[Friend]timestamp[(int)button] = Time.Duration.Ticks;
		    }
		}

		protected void OnJoystickButtonUp(uint index, uint button)
		{
		    if (index < maxControllers && button < Controller.MaxButtons)
		    {
		        nextState.[Friend]controllers[(int)index].[Friend]down[(int)button] = false;
		        nextState.[Friend]controllers[(int)index].[Friend]released[(int)button] = true;
		    }
		}

		protected void OnGamepadButtonDown(uint index, Buttons button)
		{
		    if (index < maxControllers)
		    {
		        nextState.[Friend]controllers[(int)index].[Friend]down[(int)button] = true;
		        nextState.[Friend]controllers[(int)index].[Friend]pressed[(int)button] = true;
		        nextState.[Friend]controllers[(int)index].[Friend]timestamp[(int)button] = Time.Duration.Ticks;
		    }
		}

		protected void OnGamepadButtonUp(uint index, Buttons button)
		{
		    if (index < maxControllers)
		    {
		        nextState.[Friend]controllers[(int)index].[Friend]down[(int)button] = false;
		        nextState.[Friend]controllers[(int)index].[Friend]released[(int)button] = true;
		    }
		}

		protected bool IsJoystickButtonDown(uint index, uint button)
		{
		    return (index < maxControllers && button < Controller.MaxButtons && nextState.[Friend]controllers[(int)index].[Friend]down[(int)button]);
		}

		protected bool IsGamepadButtonDown(uint index, Buttons button)
		{
		    return (index < maxControllers && nextState.[Friend]controllers[(int)index].[Friend]down[(int)button]);
		}

		protected void OnJoystickAxis(uint index, uint axis, float value)
		{
		    if (index < maxControllers && axis < Controller.MaxAxis)
		    {
		        nextState.[Friend]controllers[(int)index].[Friend]axis[(int)axis] = value;
		        nextState.[Friend]controllers[(int)index].[Friend]axisTimestamp[(int)axis] = Time.Duration.Ticks;
		    }
		}

		protected float GetJoystickAxis(uint index, uint axis)
		{
		    if (index < maxControllers && axis < Controller.MaxAxis)
		        return nextState.[Friend]controllers[(int)index].[Friend]axis[(int)axis];
		    return 0;
		}

		protected void OnGamepadAxis(uint index, Axes axis, float value)
		{
		    if (index < maxControllers)
		    {
		        nextState.[Friend]controllers[(int)index].[Friend]axis[(int)axis] = value;
		        nextState.[Friend]controllers[(int)index].[Friend]axisTimestamp[(int)axis] = Time.Duration.Ticks;
		    }
		}

		protected float GetGamepadAxis(uint index, Axes axis)
		{
		    if (index < maxControllers)
		        return nextState.[Friend]controllers[(int)index].[Friend]axis[(int)axis];
		    return 0;
		}
	}
}
