using System;

namespace Pile
{
	struct Mouse
	{
		public const int MaxButtons = MouseButtons.Count();

		internal ButtonState[MaxButtons] state = default;
		internal int64[MaxButtons] timestamp = default;
		internal Vector2 wheelValue = .Zero;

		internal this() {}

		internal void Step() mut
		{
			for (int i = 0; i < MaxButtons; i++)
				state[i] &= ~(.Pressed|.Released);

			wheelValue = .Zero;
		}

		internal void Copy(Mouse from) mut
		{
			state = from.state;
			timestamp = from.timestamp;

			wheelValue = from.wheelValue;
		}

		[Inline]
		public bool Pressed(MouseButtons button) => (state[(int)button] & .Pressed) != 0;
		[Inline]
		public bool Down(MouseButtons button) => (state[(int)button] & .Down) != 0;
		[Inline]
		public bool Released(MouseButtons button) => (state[(int)button] & .Released) != 0;

		public int64 Timestamp(MouseButtons button)
		{
		    return timestamp[(int)button];
		}

		public bool Repeated(MouseButtons button, float delay, float interval)
		{
		    if (Pressed(button))
		        return true;

			if (Down(button))
			{
			    var time = timestamp[(int)button] / (float) TimeSpan.TicksPerSecond;
	
			    return (Time.Duration.TotalSeconds - time) > delay && Time.OnInterval(interval, time);
			}

			return false;
		}

		[Inline] public bool LeftPressed => (state[(int)MouseButtons.Left] & .Pressed) != 0;
		[Inline] public bool LeftDown => (state[(int)MouseButtons.Left] & .Down) != 0;
		[Inline] public bool LeftReleased => (state[(int)MouseButtons.Left] & .Released) != 0;

		[Inline] public bool RightPressed => (state[(int)MouseButtons.Right] & .Pressed) != 0;
		[Inline] public bool RightDown => (state[(int)MouseButtons.Right] & .Down) != 0;
		[Inline] public bool RightReleased => (state[(int)MouseButtons.Right] & .Released) != 0;

		[Inline] public bool MiddlePressed => (state[(int)MouseButtons.Middle] & .Pressed) != 0;
		[Inline] public bool MiddleDown => (state[(int)MouseButtons.Middle] & .Down) != 0;
		[Inline] public bool MiddleReleased => (state[(int)MouseButtons.Middle] & .Pressed) != 0;

		[Inline] public Vector2 Wheel => wheelValue;
	}
}
