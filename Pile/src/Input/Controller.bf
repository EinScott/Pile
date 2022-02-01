using System;

namespace Pile
{
	struct Controller
	{
		public const uint MaxButtons = Buttons.Count();
		public const uint MaxAxis = Axes.Count();

		public bool Connected { [Inline]get; [Inline]private set mut; }
		public bool IsGamepad { [Inline]get; [Inline]private set mut; }
		public int Buttons { [Inline]get; [Inline]private set mut; }
		public int Axes { [Inline]get; [Inline]private set mut; }

		internal ButtonState[MaxButtons] state = .();
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

			state = default;
			timestamp = default;
			axis = default;
			axisTimestamp = default;
		}

		internal void Step() mut
		{
			for (int i = 0; i < MaxButtons; i++)
			{
				state[i] &= ~(.Pressed|.Released);
			}
		}

		internal void Copy(Controller from) mut
		{
			if (Connected != from.Connected)
			{
				Connected = from.Connected;
				IsGamepad = from.IsGamepad;
				Buttons = from.Buttons;
				Axes = from.Axes;
			}

			state = from.state;
			timestamp = from.timestamp;
			axis = from.axis;
			axisTimestamp = from.axisTimestamp;
		}

		[Inline]
		public bool Pressed(Buttons button) => (state[(int)button] & .Pressed) != 0;

		[Inline]
		public int64 Timestamp(Buttons button) => timestamp[(int)button];
		[Inline]
		public int64 Timestamp(Axes axis) => axisTimestamp[(int)axis];

		[Inline]
		public bool Down(Buttons button) => (state[(int)button] & .Down) != 0;

		[Inline]
		public bool Released(Buttons button) => (state[(int)button] & .Released) != 0;

		[Inline]
		public float Axis(Axes axis) => this.axis[(int)axis];

		[Inline]
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
