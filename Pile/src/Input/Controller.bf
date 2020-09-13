using System;

namespace Pile
{
	public class Controller
	{
		public const uint MaxButtons = 24;
		public const uint MaxAxis = 12;

		public readonly Input input;

		public bool Connected { get; private set; }
		public bool IsGamepad { get; private set; }
		public int Buttons { get; private set; }
		public int Axes { get; private set; }

		readonly bool[] pressed = new bool[MaxButtons] ~ delete _;
		readonly bool[] down = new bool[MaxButtons] ~ delete _;
		readonly bool[] released = new bool[MaxButtons] ~ delete _;
		readonly int64[] timestamp = new int64[MaxButtons] ~ delete _;
		readonly float[] axis = new float[MaxAxis] ~ delete _;
		readonly int64[] axisTimestamp = new int64[MaxAxis] ~ delete _;

		public this(Input input)
		{
			this.input = input;
		}

		void Connect(uint buttonCount, uint axisCount, bool isGamepad)
		{
		    Buttons = (int)Math.Min(buttonCount, MaxButtons);
		    Axes = (int)Math.Min(axisCount, MaxAxis);
		    IsGamepad = isGamepad;
		    Connected = true;
		}

		void Disconnect()
		{
		    Connected = false;
		    IsGamepad = false;
		    Buttons = 0;
		    Axes = 0;

			for (int i = 0; i < MaxButtons; i++)
			{
				pressed[i] = false;
				down[i] = false;
				released[i] = false;
				timestamp[i] = 0L;
			}

			for (int i = 0; i < MaxAxis; i++)
			{
				axis[i] = 0;
				axisTimestamp[i] = 0L;
			}
		}

		void Step()
		{
			for (int i = 0; i < MaxButtons; i++)
			{
				pressed[i] = false;
				released[i] = false;
			}
		}

		void Copy(Controller from)
		{
			Connected = from.Connected;
			IsGamepad = from.IsGamepad;
			Buttons = from.Buttons;
			Axes = from.Axes;

			from.[Friend]pressed.CopyTo(pressed);
			from.[Friend]down.CopyTo(down);
			from.[Friend]released.CopyTo(released);
			from.[Friend]timestamp.CopyTo(timestamp);
			from.[Friend]axis.CopyTo(axis);
			from.[Friend]axisTimestamp.CopyTo(axisTimestamp);
		}

		public bool Pressed(int buttonIndex) => buttonIndex >= 0 && buttonIndex < MaxButtons && pressed[buttonIndex];
		public bool Pressed(Buttons button) => Pressed((int)button);

		public int64 Timestamp(int buttonIndex) => buttonIndex >= 0 && buttonIndex < MaxButtons ? timestamp[buttonIndex] : 0;
		public int64 Timestamp(Buttons button) => Timestamp((int)button);
		public int64 Timestamp(Axes axis) => axisTimestamp[(int)axis];

		public bool Down(int buttonIndex) => buttonIndex >= 0 && buttonIndex < MaxButtons && down[buttonIndex];
		public bool Down(Buttons button) => Down((int)button);

		public bool Released(int buttonIndex) => buttonIndex >= 0 && buttonIndex < MaxButtons && released[buttonIndex];
		public bool Released(Buttons button) => Released((int)button);

		public float Axis(int axisIndex) => (axisIndex >= 0 && axisIndex < MaxAxis) ? axis[axisIndex] : 0f;
		public float Axis(Axes axis) => Axis((int)axis);

		public Vector2 Axis(int axisX, int axisY) => Vector2(Axis(axisX), Axis(axisY));
		public Vector2 Axis(Axes axisX, Axes axisY) => Vector2(Axis(axisX), Axis(axisY));

		public Vector2 LeftStick => Axis(Pile.Axes.LeftX, Pile.Axes.LeftY);
		public Vector2 RightStick => Axis(Pile.Axes.RightX, Pile.Axes.RightY);

		public bool Repeated(Buttons button)
		{
		    return Repeated(button, input.repeatDelay, input.repeatInterval);
		}

		public bool Repeated(Buttons button, float delay, float interval)
		{
		    if (Pressed(button))
		        return true;

		    if (Down(button))
		    {
		        var time = Timestamp(button) / (float) TimeSpan.TicksPerSecond;
		        return (Time.Duration.TotalSeconds - time) > delay && Time.OnInterval(interval, time);
		    }

		    return false;
		}
	}
}
