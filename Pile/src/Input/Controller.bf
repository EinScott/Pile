using System;

namespace Pile
{
	struct Controller
	{
		public const uint MaxButtons = 24;
		public const uint MaxAxis = 12;

		public bool Connected { get; private set mut; }
		public bool IsGamepad { get; private set mut; }
		public int Buttons { get; private set mut; }
		public int Axes { get; private set mut; }

		internal bool[MaxButtons] pressed = .();
		internal bool[MaxButtons] down = .();
		internal bool[MaxButtons] released = .();
		internal int64[MaxButtons] timestamp = .();
		internal float[MaxAxis] axis = .();
		internal int64[MaxAxis] axisTimestamp = .();

		internal this()
		{
			Connected = false;
			IsGamepad = false;
			Buttons = 0;
			Axes = 0;
		}

		internal void Connect(uint buttonCount, uint axisCount, bool isGamepad) mut
		{
		    Buttons = (int)Math.Min(buttonCount, MaxButtons);
		    Axes = (int)Math.Min(axisCount, MaxAxis);
		    IsGamepad = isGamepad;
		    Connected = true;
		}

		internal void Disconnect() mut
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

		internal void Step() mut
		{
			for (int i = 0; i < MaxButtons; i++)
			{
				pressed[i] = false;
				released[i] = false;
			}
		}

		internal void Copy(Controller from) mut
		{
			Connected = from.Connected;
			IsGamepad = from.IsGamepad;
			Buttons = from.Buttons;
			Axes = from.Axes;

			pressed = from.pressed;
			down = from.down;
			released = from.released;
			timestamp = from.timestamp;
			axis = from.axis;
			axisTimestamp = from.axisTimestamp;
		}

		[Inline]
		public bool Pressed(int buttonIndex) => buttonIndex >= 0 && buttonIndex < MaxButtons && pressed[buttonIndex];
		public bool Pressed(Buttons button) => Pressed((int)button);

		public int64 Timestamp(int buttonIndex) => buttonIndex >= 0 && buttonIndex < MaxButtons ? timestamp[buttonIndex] : 0;
		public int64 Timestamp(Buttons button) => Timestamp((int)button);
		public int64 Timestamp(Axes axis) => axisTimestamp[(int)axis];

		[Inline]
		public bool Down(int buttonIndex) => buttonIndex >= 0 && buttonIndex < MaxButtons && down[buttonIndex];
		public bool Down(Buttons button) => Down((int)button);

		[Inline]
		public bool Released(int buttonIndex) => buttonIndex >= 0 && buttonIndex < MaxButtons && released[buttonIndex];
		public bool Released(Buttons button) => Released((int)button);

		[Inline]
		public float Axis(int axisIndex) => (axisIndex >= 0 && axisIndex < MaxAxis) ? axis[axisIndex] : 0f;
		public float Axis(Axes axis) => Axis((int)axis);

		[Inline]
		public Vector2 Axis(int axisX, int axisY) => Vector2(Axis(axisX), Axis(axisY));
		public Vector2 Axis(Axes axisX, Axes axisY) => Vector2(Axis(axisX), Axis(axisY));

		[Inline] public Vector2 LeftStick => Axis(Pile.Axes.LeftX, Pile.Axes.LeftY);
		[Inline] public Vector2 RightStick => Axis(Pile.Axes.RightX, Pile.Axes.RightY);

		public bool Repeated(Buttons button)
		{
		    return Repeated(button, Input.repeatDelay, Input.repeatInterval);
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
